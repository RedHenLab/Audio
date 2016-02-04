/***************************************************************************
*                                                                          *                     
* Panako - acoustic fingerprinting                                         *   
* Copyright (C) 2014 - Joren Six / IPEM                                    *   
*                                                                          *
* This program is free software: you can redistribute it and/or modify     *
* it under the terms of the GNU Affero General Public License as           *
* published by the Free Software Foundation, either version 3 of the       *
* License, or (at your option) any later version.                          *
*                                                                          *
* This program is distributed in the hope that it will be useful,          *
* but WITHOUT ANY WARRANTY; without even the implied warranty of           *
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *
* GNU Affero General Public License for more details.                      *
*                                                                          *
* You should have received a copy of the GNU Affero General Public License *
* along with this program.  If not, see <http://www.gnu.org/licenses/>     *
*                                                                          *
****************************************************************************
*    ______   ________   ___   __    ________   ___   ___   ______         *
*   /_____/\ /_______/\ /__/\ /__/\ /_______/\ /___/\/__/\ /_____/\        *      
*   \:::_ \ \\::: _  \ \\::\_\\  \ \\::: _  \ \\::.\ \\ \ \\:::_ \ \       *   
*    \:(_) \ \\::(_)  \ \\:. `-\  \ \\::(_)  \ \\:: \/_) \ \\:\ \ \ \      * 
*     \: ___\/ \:: __  \ \\:. _    \ \\:: __  \ \\:. __  ( ( \:\ \ \ \     * 
*      \ \ \    \:.\ \  \ \\. \`-\  \ \\:.\ \  \ \\: \ )  \ \ \:\_\ \ \    * 
*       \_\/     \__\/\__\/ \__\/ \__\/ \__\/\__\/ \__\/\__\/  \_____\/    *
*                                                                          *
****************************************************************************
*                                                                          *
*                              Panako                                      * 
*                       Acoustic Fingerprinting                            *
*                                                                          *
****************************************************************************/




package be.panako.cli;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.jar.Attributes;
import java.util.jar.Manifest;
import java.util.logging.Logger;

import be.panako.strategy.QueryResult;
import be.panako.strategy.QueryResultWithMatchName;
import be.panako.strategy.Strategy;
import be.panako.util.Config;
import be.panako.util.Key;
import be.panako.util.TimeUnit;
import be.panako.util.Trie;
import be.tarsos.dsp.io.PipeDecoder;
import be.tarsos.dsp.io.PipedAudioStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.logging.LogManager;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * The main starting point for the application. Does some argument parsing and
 * delegates to the right sub-applications.
 * 
 * @author Joren Six
 */
public class Panako {
	
	private final static Logger LOG = Logger.getLogger(Panako.class.getName());
	
        private final static File fingerprintingOutput = new File("fingerprint-detection.log");
        
        private final static File segmentationOutput = new File("broadcast-segmentation.log");

        private static BufferedWriter segmentationWriter;
        
        private static BufferedWriter fingerprintWriter;
        
        public static List<QueryResultWithMatchName> queryResultList = new ArrayList<>();
        
	/**
	 * A static string describing the default microphone. It is used in the monitor command.
	 */
	public final static String DEFAULT_MICROPHONE = "DEFAULT_MICROPHONE";

    

        
	
	/**
	 * A map of applications, maps the name of the application to the instance.
	 */
	private final transient Map<String, Application> applications;
	/**
	 * For autocomplete, use a trie;
	 */
	private final Trie applicationTrie;
	
	private static Application currentApplication;
	
	public static Application getCurrentApplication(){
		return currentApplication;
	}
	

	public Panako() {
		//Initialize configuration:
		Config.getInstance();
		
		// Initializes the CLI application list.
		applications = new HashMap<String, Application>();
		
		//for auto completion
		applicationTrie = new Trie();
		registerApplications();
		
		//decoder settings
		String pipeEnvironment = Config.get(Key.DECODER_PIPE_ENVIRONMENT);
		String pipeArgument = Config.get(Key.DECODER_PIPE_ENVIRONMENT_ARG);
		String pipeCommand = Config.get(Key.DECODER_PIPE_COMMAND);
		String pipeLogFile = Config.get(Key.DECODER_PIPE_LOG_FILE);
		int pipeBuffer = Config.getInt(Key.DECODER_PIPE_BUFFER_SIZE);
                
                //uncomment for normal console notification
                LogManager.getLogManager().reset();
		
		//initialize the decoder
		PipeDecoder decoder = new PipeDecoder(pipeEnvironment, pipeArgument, pipeCommand, pipeLogFile, pipeBuffer);
		PipedAudioStream.setDecoder(decoder);
	}
	
	 /**
	 * Registers a list of CLI applications.
	 */
	private void registerApplications() {
		final List<Application> applicationList = new ArrayList<Application>();
		applicationList.add(new Query());
		applicationList.add(new Stats());
		applicationList.add(new Store());
		applicationList.add(new Configuration());
		applicationList.add(new Play());
		applicationList.add(new Browser());
		applicationList.add(new Monitor());
		applicationList.add(new Sync());
		applicationList.add(new Compare());
		for (final Application application : applicationList) {
			applications.put(application.name(), application);
			applicationTrie.insert(application.name());
		}
	}

	private void startApplication(String[] arguments) {
		String application = "";
		String[] applicationArguments = null;
		if (arguments.length > 0) {
			arguments = filterAndSetConfigurationArguments(arguments);
			application = arguments[0];
			applicationArguments = new String[arguments.length - 1];
			for (int i = 1; i < arguments.length; i++) {
				applicationArguments[i - 1] = arguments[i];
			}
		}
		if(containsVersionArgument(arguments)){
			printVersion();
		}else{
			actuallyStartApplication(application,applicationArguments);
		}
	}
	
	/**
	 * Prints version information found in the manifest file.
	 */
	private void printVersion() {
		System.out.println();
		Class<Panako> clazz = Panako.class;
		String className = clazz.getSimpleName() + ".class";
		String classPath = clazz.getResource(className).toString();
		if (!classPath.startsWith("jar")) {
			System.out.println("Panako version xxx");
		}else{
			try {
				String manifestPath = classPath.substring(0, classPath.lastIndexOf("!") + 1) + "/META-INF/MANIFEST.MF";
				Manifest manifest;
				manifest = new Manifest(new URL(manifestPath).openStream());
				Attributes attr = manifest.getMainAttributes();
				String buildDate = attr.getValue("Built-Date");
				String builtBy = attr.getValue("Built-By");
				String version = attr.getValue("Implementation-Version");
				System.out.println("Panako Acoustic Fingerprinting, by " + builtBy);
				System.out.println("  Built on: " + buildDate);
				System.out.println("  Version: " + version);
			} catch (MalformedURLException e) {
				//ignore
			} catch (IOException e) {
				//ignore
			}
		}
		
	}

	private void actuallyStartApplication(String application, String[] applicationArguments) {
		
		if (!applications.containsKey(application)) {
			Collection<String> completions = applicationTrie.autoComplete(application);
			//found one match, it is the application to start
			if(completions.size()==1){
				application = completions.iterator().next();
			}
		}
		
		if (applications.containsKey(application)) {
			Application app = applications.get(application);
			if(containsHelpArgument(applicationArguments)){
				//show help for the application
				System.out.println("Name");
				System.out.println("\t" + application);
				System.out.println("Synopsis");
				System.out.println("\tpanako " + application + " " + app.synopsis());
				System.out.println("Description");
				System.out.println("\t" + app.description());				
			}else{
				Panako.currentApplication = app;
                                if(app.writesToFile()) {
                                    try {
                                        segmentationWriter = new BufferedWriter(new FileWriter(segmentationOutput));
                                        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(Calendar.getInstance().getTime());
                                        segmentationWriter.write(timeStamp+"\n");
                                        segmentationWriter.flush();
                                        if (Config.getBoolean(Key.DEBUG)) {
                                            fingerprintWriter = new BufferedWriter(new FileWriter(fingerprintingOutput));
                                            fingerprintWriter.write(timeStamp+"\n");
                                            fingerprintWriter.flush();
                                        }
                                    } catch(IOException e) {
                                        LOG.severe("IOException @ filewriter file creation");
                                        e.printStackTrace();
                                    }
                                }
				if(app.needsStorage()){
					boolean storageIsAvailable = Strategy.getInstance().isStorageAvailable();
					if(storageIsAvailable){
						actuallyReallyStartApplication(app,applicationArguments);
					}else{
						System.out.println("Storage not available!");
						System.err.println("Storage not available!");
					}
				}else{
					actuallyReallyStartApplication(app,applicationArguments);
				}
                                
			}
		} else {			 
			System.out.println("Unknown application '"+ application + "'. Valid applications are:");
			for (final String key : applications.keySet()) {
				System.out.println("\t" + key);
				System.out.println("\t\t" + applications.get(key).description());
			}
		}
	}
	
	private void actuallyReallyStartApplication(Application app,String[] applicationArguments){
		//run the application
		LOG.info(String.format("Starting Panako application %s with %d arguments",app.name(),applicationArguments.length));
		app.run(applicationArguments);
	}
	
	/**
	 * Filters out the configuration parameters from a set of arguments and
	 * sets the configuration to the configured value.
	 * e.g. if <code>DB_NAME</code> is a configuration parameter the following
	 * overrides the configured file settings:
	 * <code>panako stats DB_NAME=blaat</code>
	 * <p>In the value of the configured parameter no spaces are allowed.</p>
	 * @param arguments the arguments to filter
	 * @return a filtered set of arguments, with only real arguments..
	 */
	private String[] filterAndSetConfigurationArguments(String[] arguments){
		ArrayList<String> filteredArguments = new ArrayList<String>();
		//a set with all the configuration names
		HashSet<String> keys = new HashSet<String>();
		for(Key key : Key.values()){
			keys.add(key.name());
		}
		//iterate all arguments
		for(String argument:arguments){
			//if the argument contains a = and the first part corresponds to 
			//a value in the hashset
			if(argument.contains("=") && keys.contains(argument.split("=")[0])){
				String configurationKey = argument.split("=")[0];
				String configurationValue = argument.split("=")[1];
				Config.set(Key.valueOf(configurationKey),configurationValue);
			}else{
				//normal argument
				filteredArguments.add(argument);
			}
		}
		return filteredArguments.toArray (new String[filteredArguments.size ()]);
	}

	private boolean containsHelpArgument(String[] args){
		boolean containsHelp = false;
		for(String argument : args){
			containsHelp = containsHelp 
			|| argument.equalsIgnoreCase("-h") 
			|| argument.equalsIgnoreCase("--help");
		}
		return containsHelp;
	}
	
	private boolean containsVersionArgument(String[] args){
		boolean containsVersion = false;
		for(String argument : args){
			containsVersion = containsVersion 
			|| argument.equalsIgnoreCase("-v") 
			|| argument.equalsIgnoreCase("--version");
		}
		return containsVersion;
	}
	
	
	public static String printQueryResult(String query,QueryResult r){
		String queryInfo = String.format("%s;%.0f;%.0f;",query,r.queryTimeOffsetStart,r.queryTimeOffsetStop);
		String matchInfo = String.format("%s;%s;%.0f;%.0f;", r.identifier,r.description,r.time,r.score);
		String factorInfo = String.format("%.0f%%;%.0f%%", r.timeFactor,r.frequencyFactor);
//		System.out.println(queryInfo+matchInfo+factorInfo);
                return queryInfo+matchInfo+factorInfo;
	}
	
	public static String printQueryResultHeader(){
		String header;
		header = "Query;Query start (s);Query stop (s); Match Identifier;Match description; Match start (s); Match score; Time factor (%); Frequency factor(%)"; 
//		System.out.println(header);
                return header;
	}
        
        public static void analyzeQueryResult(Strategy strategy, String filePath, QueryResult result) {
            try {
//                System.out.println("analyzeQueryResult");
                if (result.score > 0) {
                    QueryResultWithMatchName resultWithMatchName = new QueryResultWithMatchName(result, filePath);
                    queryResultList.add(resultWithMatchName);
                    if (Config.getBoolean(Key.DEBUG)) {
                        fingerprintWriter.write(filePath + " matched with " + result.description + "\nscore:" + result.score + "; time:"+ result.time + 
                            "; match time start:"+ result.queryTimeOffsetStart + "; match time stop:"+ result.queryTimeOffsetStop+"\n");
                        fingerprintWriter.flush();  
                    }
                } else {
//                    if (Config.getBoolean(Key.DEBUG)) {
//                        writer.write(filePath + " DID NOT match with " + result.description + "\nscore:" + result.score + "; time:"+ result.time + 
//                            "; match time start:"+ result.queryTimeOffsetStart + "; match time stop:"+ result.queryTimeOffsetStop+"\n");
//                        writer.flush();
//                    }
                }
            }catch(IOException e) {
                LOG.severe("IOException @ analyzeQueryResult");
                e.printStackTrace();
            }
//            System.out.println(printQueryResult("query-test", result));
        }
        
        public static void generateSegmentation() {
//            System.out.println("generateSegmentation");
            int i = 0;
            int j = 1;
            int segmentStart = 0;
            int segmentEnd = 0;
            int oldMatchStart = 0;
            int oldMatchEnd = 0;
            int matchStart = 0;
            int matchEnd = 0;
            boolean segmentOngoing = true;
            boolean lastSegment = false;
            
            System.out.println("sorting query matches...");
            Collections.sort(queryResultList, new Comparator<QueryResultWithMatchName>() {
                public int compare(QueryResultWithMatchName r1, QueryResultWithMatchName r2) {
                    String regex = "_|\\.";
                    String[] clipTimes1 = r1.matchName.split(regex);
                    String[] clipTimes2 = r2.matchName.split(regex);
                    int start1 = Integer.parseInt(clipTimes1[clipTimes1.length-3]);
                    int start2 = Integer.parseInt(clipTimes2[clipTimes2.length-3]);
                    if (start1 < start2) {
                        return -1;
                    } else if (start2 > start1) {
                        return 1;
                    } else {
                        return 0;
                    }
                }
            });
            System.out.println("...done.");
            
            for (QueryResultWithMatchName result : queryResultList) {
//                System.out.println(result.toString());
                if (queryResultList.indexOf(result) == queryResultList.size()-1) {
                    lastSegment = true;
                }
                        
                String regex = "_|\\.";
                String[] clipTimes = result.matchName.split(regex);
//                if (Config.getBoolean(Key.DEBUG)) {
//                    for (String time : clipTimes) {
//                        System.out.println(time);   
//                    }
//                }
                oldMatchStart = matchStart;
                oldMatchEnd = matchEnd;
                matchStart = Integer.parseInt(clipTimes[clipTimes.length-3]);
                matchEnd = Integer.parseInt(clipTimes[clipTimes.length-2]);
                boolean overlap = matchStart <= (oldMatchEnd+30);
                segmentOngoing = segmentOngoing && overlap;
//                System.out.println(matchStart+" "+oldMatchEnd+ " " + overlap);
                String matchedTrack = result.description;
                
                if (i == 0) {
                    segmentStart = matchStart;
                    segmentEnd = matchEnd;
                    oldMatchEnd = matchEnd;
                    segmentOngoing = true;
                }
                
                if (lastSegment) {
                    oldMatchEnd = matchEnd;
                }
                
                if (matchedTrack.contains("Commercial")) {
                    if (!segmentOngoing || lastSegment) {
                        // print information for the previous segment
                        try {
                            segmentationWriter.write("Commercial Segment Number "+j+":\n");

                            int hours = segmentStart / 3600;
                            int minutes = (segmentStart % 3600) / 60;
                            String output = String.format("Start: [%02dh::%02dm::%02ds]\n", hours, minutes, segmentStart%60);
                            segmentationWriter.write(output);

                            hours = oldMatchEnd / 3600;
                            minutes = (oldMatchEnd % 3600) / 60;
                            output = String.format("End: [%02dh::%02dm::%02ds]\n", hours, minutes, oldMatchEnd%60);
                            segmentationWriter.write(output);

                            segmentationWriter.flush();
                        } catch(IOException e) {
                            LOG.severe("IOException @ generateSegmentation");
                            e.printStackTrace();
                        }
                        
                        // start a new segment 
                        segmentStart = matchStart;
                        segmentOngoing = true;
                        j++;
                    }
                    else {
                        segmentEnd = matchEnd;
                    } 
                }
                i++;
            }
        }

	/**
	 * Starts the Panako application. It is the main (and only) entry point.
	 * @param args The command line arguments
	 */
	public static void main(String[] args) {
		//Initialize Panako
		Panako panako = new Panako();
		//Run a the application
		panako.startApplication(args);
	}
}
