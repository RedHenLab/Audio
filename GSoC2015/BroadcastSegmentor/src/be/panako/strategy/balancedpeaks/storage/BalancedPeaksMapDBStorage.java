
package be.panako.strategy.balancedpeaks.storage;

import be.panako.cli.Panako;
import be.panako.strategy.balancedpeaks.BalancedPeaksFingerprint;
import be.panako.strategy.fft.FFTFingerprint;
import be.panako.strategy.fft.storage.FFTFingerprintQueryMatch;
import be.panako.strategy.nfft.storage.NFFTMapDBStorage;
import be.panako.util.Config;
import be.panako.util.FileUtils;
import be.panako.util.Key;
import java.io.File;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.NavigableSet;
import java.util.Set;
import java.util.concurrent.ConcurrentNavigableMap;
import java.util.logging.Logger;
import org.mapdb.Atomic;
import org.mapdb.BTreeKeySerializer;
import org.mapdb.DB;
import org.mapdb.DBMaker;
import org.mapdb.Fun;

/**
 * A singleton class that interacts with a MapDB. It acts as a database controller.
 * @author Mattia Cerrato <mattia.cerrato@edu.unito.it>
 */
public class BalancedPeaksMapDBStorage {
    private static BalancedPeaksMapDBStorage instance;
    private final DB db;
    private final static Logger LOG = Logger.getLogger(BalancedPeaksMapDBStorage.class.getName());
    
    /**
    * A mutex for synchronization purposes
    */
    private static Object mutex = new Object();
    
    private ConcurrentNavigableMap<Integer, String> audioNameStore;

    private NavigableSet<Fun.Tuple3<Integer, Integer, Integer>> balPeaksFingerprintStore;

    private Atomic.Long secondsCounter;

    
    private BalancedPeaksMapDBStorage() {
        final String audioStore = "audio_store";
        final String balPeaksStore = "balpeaks_store";
        
        File dbFile = new File(Config.get(Key.BALPEAKS_MAPDB_DATABASE));
        
        // if this application writes to storage (i.e. store) and a dbfile has not yet been created
        if (Panako.getCurrentApplication().writesToStorage() || !dbFile.exists()) {
            // create it
            db = DBMaker.newFileDB(dbFile)
                .closeOnJvmShutdown() // close the database automatically
                .make();
            
            // create a meta-data storage. unclear what this is. maybe the .t and .d db files?
            audioNameStore = db.createTreeMap(audioStore)
                    .counterEnable()
                    .makeOrGet();
            
            balPeaksFingerprintStore = db.createTreeSet(balPeaksStore)
                .counterEnable() // enable size counter
                .serializer(BTreeKeySerializer.TUPLE3)
                .makeOrGet();
            
            // create a seconds counter
            secondsCounter = db.getAtomicLong("seconds_counter");
        }
        // the db is needed, but in read-only mode
        else if (Panako.getCurrentApplication().needsStorage()) {
            db = DBMaker.newFileDB(dbFile)
                .closeOnJvmShutdown() // close the database automatically
                .readOnly() // make the database read only
                .make();
            
            audioNameStore = db.getTreeMap(audioStore);
            balPeaksFingerprintStore = db.getTreeSet(balPeaksStore);
            secondsCounter = db.getAtomicLong("seconds_counter");
        }
        // no db is really needed
        else {
            secondsCounter = null;
            audioNameStore = null;
            balPeaksFingerprintStore = null;
            db = null;
        }
    }
    
    public static BalancedPeaksMapDBStorage getInstance() {
        if (instance == null) {
            synchronized(mutex) {
                if (instance == null) {
                    return new BalancedPeaksMapDBStorage();
                }
            }
        }
        return instance;
    }
    
    private void checkAndCreateLock(File dbFile) {
        // Multiple processes should not write to the same database
        // Check for a lock and quit if there is one.
        if (FileUtils.isFileLocked(dbFile.getAbsolutePath())) {
            String message = "The database is locked.\nMultiple processes should not write to the same database at the same time.\n"
                            + "If no other processes use the database, remove '"
                            + FileUtils.getLockFileName(dbFile.getAbsolutePath())
                            + "' manually.";
            System.out.println(message);
            System.err.println(message);
            LOG.severe(message);
            throw new RuntimeException(message);
        }

        // Create a lock, quit if there is a problem creating the lock.
        if (!FileUtils.createLock(dbFile.getAbsolutePath())) {
            String message = "Could not create a lock file for the database. \n"
                            + "Please make sure that '"
                            + FileUtils.getLockFileName(dbFile.getAbsolutePath())
                            + "' is writable.";
            System.out.println(message);
            System.err.println(message);
            LOG.severe(message);
            throw new RuntimeException(message);
        }
    }
    
    public List<BalancedPeaksFingerprintQueryMatch> getMatches(List<BalancedPeaksFingerprint> fingerprints, int maxNumberOfMatches) {
        Set<BalancedPeaksFingerprintQueryMatch> matchesList = new HashSet<>();
        return null;
    }

    public boolean hasDescription(String description) {
        // non c'è il controllo dei duplicati nel database, per ora. TODO
        return false;
    }

    public void addAudio(int identifier, String description) {
        audioNameStore.put(identifier, description);
    }

    public float addFingerprint(int identifier, int t1, int hash) {
        balPeaksFingerprintStore.add(Fun.t3(hash, t1, identifier));
        return 0.0f;
    }
}
