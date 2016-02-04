/***************************************************************************
*                                                                          *                     
* Panako - acoustic fingerprinting                                         *   
* Copyright (C) 2014 - Mattia Cerrato                                      *   
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


package be.panako.strategy.balancedpeaks;

import be.panako.strategy.QueryResult;
import be.panako.strategy.QueryResultHandler;
import be.panako.strategy.Strategy;
import be.panako.strategy.balancedpeaks.storage.BalancedPeaksFingerprintHit;
import be.panako.strategy.balancedpeaks.storage.BalancedPeaksFingerprintQueryMatch;
import be.panako.strategy.balancedpeaks.storage.BalancedPeaksMapDBStorage;
import be.panako.util.Config;
import be.panako.util.FileUtils;
import be.panako.util.Key;
import be.tarsos.dsp.AudioDispatcher;
import be.tarsos.dsp.io.jvm.AudioDispatcherFactory;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Logger;
/**
 *
 * @author Mattia Cerrato <mattia.cerrato@edu.unito.it>
 */
public class BalancedPeaksStrategy extends Strategy {
    private final static Logger LOG = Logger.getLogger(BalancedPeaksStrategy.class.getName());

    private final BalancedPeaksMapDBStorage storage;

    public BalancedPeaksStrategy() {
        storage = BalancedPeaksMapDBStorage.getInstance();
    }
    
    @Override
    public double store(String resource, String description) {
        double durationInSeconds;
        final int identifier = FileUtils.getIdentifier(resource);
//        System.out.println("hello store!");
        if (storage.hasDescription(description)) {
            LOG.warning("Skipping "+resource+" store: already in database");
            durationInSeconds = -1;
        }
        else {            
            int samplerate = Config.getInt(Key.BALPEAKS_SAMPLE_RATE);
            int size = Config.getInt(Key.BALPEAKS_FFT_SIZE);
            int overlap = size - Config.getInt(Key.BALPEAKS_FFT_STEP_SIZE);
            int lookahead = Config.getInt(Key.BALPEAKS_LOOKAHEAD);
            AudioDispatcher dispatcher = AudioDispatcherFactory.fromPipe(resource, samplerate, size, overlap);
            final BalancedPeaksEventPointProcessor peakExtractor = new BalancedPeaksEventPointProcessor(size, overlap, samplerate, lookahead);
            dispatcher.addAudioProcessor(peakExtractor);
            dispatcher.run();
            List<BalancedPeaksEventPoint> peakList = peakExtractor.getPeaks();
            List<BalancedPeaksFingerprint> fingerprintList = peakExtractor.getFingerprints();
//            toTextFile(fingerprintList, "../test-fingerprints.txt");
            
//            System.out.println(fingerprintList.size());
            for(BalancedPeaksFingerprint fingerprint : fingerprintList) {
                storage.addFingerprint(identifier, fingerprint.t1, fingerprint.getHash());
            }
            storage.addAudio(identifier, description);
            // why did I put this here again?
            Set<BalancedPeaksFingerprint> fingerprintSet = new HashSet<>();
            return -1;
        }
        return durationInSeconds;
    }
    
    @Override
    public QueryResult query(String query, final int maxNumberOfResults, QueryResultHandler handler) {
        // di nuovo get dell'istanza del dbcontroller?
        double durationInSeconds;
        final List<BalancedPeaksFingerprintQueryMatch> queryMatchList = new ArrayList<>();
        final int identifier = FileUtils.getIdentifier(query);
        int samplerate = Config.getInt(Key.BALPEAKS_SAMPLE_RATE);
        int size = Config.getInt(Key.BALPEAKS_FFT_SIZE);
        int overlap = size - Config.getInt(Key.BALPEAKS_FFT_STEP_SIZE);
        int lookahead = Config.getInt(Key.BALPEAKS_LOOKAHEAD);
        AudioDispatcher dispatcher = AudioDispatcherFactory.fromPipe(query, samplerate, size, overlap);
        final BalancedPeaksEventPointProcessor peakExtractor = new BalancedPeaksEventPointProcessor(size, overlap, samplerate, lookahead);
        dispatcher.addAudioProcessor(peakExtractor);
        dispatcher.run();
        List<BalancedPeaksEventPoint> peakList = peakExtractor.getPeaks();
        List<BalancedPeaksFingerprint> fingerprintList = peakExtractor.getFingerprints();
        
        List<BalancedPeaksFingerprintQueryMatch> matchList = storage.getMatches(fingerprintList, maxNumberOfResults);
        
        System.out.println("hello query!");
        // da capire: queryhandler, riga 129 di fftstrategy
        
        return null;
    }

    @Override
    public void printStorageStatistics() {
        throw new UnsupportedOperationException("Unsupported as of now.");
    }
    
    @Override
    public boolean isStorageAvailable() {
        // non mi curo ancora della concorrenza di più query, TODO
        return true;
    }
    
    @Override
    public boolean hasResource(String resource) {
        // ancora cose sulla concorrenza e le risorse (le entry di una hashmap, mi pare). TODO

        // ritorno false in modo che - per ora - non vengano mai percepiti i duplicati nel db
        // (che poi non esiste). TODO

        return false;
    }
    
    @Override
    public void monitor(String query, final int maxNumberOfReqults, final QueryResultHandler handler) {
        // di nuovo get dell'istanza del dbcontroller?
    }

    private void toTextFile(List<BalancedPeaksFingerprint> fingerprintList, String path) {
        try {
            PrintWriter writer = new PrintWriter(new File(path));
            writer.format("%10s %10s %10s %10s\n", "Bin1", "Bin2", "timeDiff", "hash");
            for(BalancedPeaksFingerprint fingerprint : fingerprintList) {
                writer.format("%10d %10d %10d %10d\n", fingerprint.b1, fingerprint.b2, 
                        fingerprint.t2 - fingerprint.t1, fingerprint.getHash());
            }
        } catch(FileNotFoundException e) {
            System.out.println(e.getMessage());
        }
    }
}
