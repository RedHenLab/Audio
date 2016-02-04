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


/** ==TODO== 
 * In a BalancedPeaks strategy, a fingerprint is a pair of spectrogram peaks. 
 * The fingerprint is identified by its hash value
 * @author Mattia Cerrato <mattia.cerrato@edu.unito.it>
 */
public class BalancedPeaksFingerprint {
    // the analysis frame at which the two peaks were detected
    public int t1;
    public int t2;
    
    // the fft bin at which the two peaks were detected
    public int b1;
    public int b2;
    
    private int hash;
    
    public BalancedPeaksFingerprint(int t1, int t2, int b1, int b2) {
        this.t1 = t1;
        this.t2 = t2;
        this.b1 = b1;
        this.b2 = b2;
    }
    
    public BalancedPeaksFingerprint(BalancedPeaksEventPoint p1, BalancedPeaksEventPoint p2) {
        this.t1 = p1.getTime();
        this.t2 = p2.getTime();
        this.b1 = p1.getBin();
        this.b2 = p2.getBin();
    }

    public void generateHash() {
        final int fixedBinaryLength = 10;
        int binaryLengthDiff;
        int timeDiff = t2 - t1;
        
        // convert the time difference between the peaks to 10-bit binary string
        String timeDiffBinary = Integer.toBinaryString(timeDiff);
        binaryLengthDiff = fixedBinaryLength - timeDiffBinary.length();
        for (int i = 0; i < binaryLengthDiff; i++) {
            timeDiffBinary = "0" + timeDiffBinary;
        }
        assert timeDiffBinary.length() == 10;
        
        // do the same for the anchor peak bin...
        String b1Binary = Integer.toBinaryString(b1);
        binaryLengthDiff = fixedBinaryLength - b1Binary.length();
        for (int i = 0; i < binaryLengthDiff; i++) {
            b1Binary = "0" + b1Binary;
        }
        assert b1Binary.length() == 10;
        
        // ... and for the coupled peak bin
        String b2Binary = Integer.toBinaryString(b2);
        binaryLengthDiff = fixedBinaryLength - b2Binary.length();
        for (int i = 0; i < binaryLengthDiff; i++) {
            b2Binary = "0" + b2Binary;
        }
        if (b2Binary.length() > 10) {
            System.out.println(b2);
            System.out.println(t2);
            System.out.println(b2Binary.length());
        }
        
        // simply concat the 3 binary strings and convert the result into an integer. 2^30 possible hash values.
        String binaryHash = b1Binary + b2Binary + timeDiffBinary;
        this.hash = Integer.parseInt(binaryHash, 2);
    }
    
    public int getHash() {
        return hash;
    }
}
