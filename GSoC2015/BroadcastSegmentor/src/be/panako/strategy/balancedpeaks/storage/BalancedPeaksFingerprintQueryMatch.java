/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package be.panako.strategy.balancedpeaks.storage;

import be.panako.util.Config;
import be.panako.util.Key;

/**
 * A data structure that provides utility to build a query match. 
 * @author Mattia Cerrato <mattia.cerrato@edu.unito.it>
 */
public class BalancedPeaksFingerprintQueryMatch {
    // for when multiple queries are requested at a time
    public int identifier;
    // start time of the match
    public double startTime;
    // a score representing a similarity value between the database track and the matched recording
    public int score;
    public int mostPopularOffset;
    
    public double getStartTime() {
        float fftHopSizesS = Config.getInt(Key.BALPEAKS_FFT_STEP_SIZE) / (float) Config.getInt(Key.BALPEAKS_SAMPLE_RATE);
        return mostPopularOffset * fftHopSizesS;
    }
    
}
