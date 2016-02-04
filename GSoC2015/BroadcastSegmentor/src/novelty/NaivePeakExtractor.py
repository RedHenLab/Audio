import numpy as nmp
import matplotlib as mpl
import matplotlib.pyplot as p
import argparse as arg
import os.path
from scipy import stats

class Peak:
    timeStamp = 0
    magnitudeValue = 0
    fftbin = 0

    def __init__(self, timeStamp, magnitudeValue, fftbin):
        self.timeStamp = timeStamp
        self.magnitudeValue = magnitudeValue
        self.fftbin = fftbin

    def __str__(self):
        return 'timeStamp: ' + str(self.timeStamp) + ' magnitudeValue: ' + str(self.magnitudeValue) + ' bin: ' +str(self.fftbin)

    def __repr__(self):
        return str(self)

# rotate a matrix (a list of lists) counterclockwise, to make it convenient for matplotlib to plot it
def ccwRotation(matrix):
    reverse_matrix = matrix[::1]
    rotated_matrix = zip(*reverse_matrix)
    return rotated_matrix

# parse a Yaafe log containing a MagnitudeSpectrum analysis. examples can be found in ./analysis-files
def parseYaafeFile(filePath):
    magnitudeSpectrumFile = open(filePath)
    # cut the first 5 lines from the yaafe log while creating a list with the remaining lines
    magnitudeSpectrumLines = magnitudeSpectrumFile.readlines()[5:]
    magnitudeSpectrum = []
    # for each analysis frame computed by Yaafe (each line in the file)
    for line in magnitudeSpectrumLines:
        # separate further each line taking comma as a separator
        line = line.split(",")
        floatList = []
        for exp_number in line:
            # convert from exponential notation to 8-digits floats
            floatList.append(float("%8f" % float(exp_number)))
        # the resulting list of lists is a matrix representing the magnitude spectrum
        magnitudeSpectrum.append(floatList)
    return magnitudeSpectrum

def findPeaks(magnitudeSpectrum):
    peakList = []
    i = 0
    # iterate over each row in the matrix (each list in the list of lists)
    for line in magnitudeSpectrum:
        # find the threshold magnitude value for peak detection
        threshold = stats.scoreatpercentile(line, 99)
        j = 0
        # iterate over the magnitude values for each fft bin in a single analysis frame (a row in the matrix)
        for value in line:
            if (value > threshold):
                peak = Peak(i, value, j)
                peakList.append(peak)
            j += 1
        i += 1
    return peakList

# create a list of peaks in a more "plottable" form, ignoring the magnitude value
def peaksPlotForm(peakList):
    peaksPlotList = []
    for peak in peakList:
        peakTuple = (peak.timeStamp, peak.fftbin)
        peaksPlotList.append(peakTuple)
    return peaksPlotList

def file_exists(parser, filepath):
    if not os.path.exists(filepath):
        parser.error("File %s does not exist" %filepath)
    else:
        return filepath

# argparse set-up
parser = arg.ArgumentParser(description="Extract spectrogram peaks and plot them from a Yaafe Magnitude Spectrum analysis")
parser.add_argument('filename',  metavar='FILEPATH', help="file containing the Yaafe analysis", type=lambda x: file_exists(parser, x))
args = parser.parse_args()

# main program logic
magnitudeSpectrum = parseYaafeFile(str(args.filename))
magnitudeSpectrumPeaks = findPeaks(magnitudeSpectrum)
# uncomment this line if you want the program to print a list of the found peaks. warning: might be a very long output
# print magnitudeSpectrumPeaks
plottablePeaks = peaksPlotForm(magnitudeSpectrumPeaks)
rotatedSpectrum = ccwRotation(magnitudeSpectrum)

# matplotlib set-up
fig = p.figure(1)
p.subplot(211)
colorMap = mpl.colors.LinearSegmentedColormap.from_list('colormap', ['blue', 'red', 'yellow', 'white'], 128)
img = p.imshow(rotatedSpectrum, interpolation='nearest', cmap=colorMap, origin='lower')
p.subplot(212)
p.scatter(*zip(*plottablePeaks))
p.show()
