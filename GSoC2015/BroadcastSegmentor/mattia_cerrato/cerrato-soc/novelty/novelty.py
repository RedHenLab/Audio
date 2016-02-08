import numpy.fft
from scipy.io import wavfile
import sys
import math
import csv
import matplotlib.pyplot as plt


# TODO: windowing function
def extractSpectrogramMatrix(path):
    fftStepSize = 4096
    sf, data = wavfile.read(path)
    left_channel = data.T[0]
    # checking whether the input file is mono or stereo.
    if type(left_channel).__name__ == "int16":
        print "mono file"
        left_channel = data
    if data.dtype == "int16":
        # da complemento a 2 a [-1, 1]
        left_channel_norm = left_channel / (2.**15)
    else:
        print "unsupported wav type: "+str(data.dtype)
        return
#   left_channel_fft = numpy.fft.fft(left_channel_norm)
#   left_channel_fft = list(math.log(abs(elem)) for elem in left_channel_fft)
    samplesCont = 0
    total_fft = []
    global fileLengthInSamples
    fileLengthInSamples = len(left_channel)
    while samplesCont < len(left_channel) - fftStepSize: # drops the last incomplete frame
        frame_fft = numpy.fft.fft(left_channel_norm[samplesCont:samplesCont+fftStepSize-1])
        frame_fft = frame_fft[0:math.ceil((fftStepSize+1)/2)]
        frame_fft = abs(frame_fft)
        frame_fft = frame_fft / float(fftStepSize)
        frame_fft = frame_fft**2
        if fftStepSize % 2 > 0:
            frame_fft[1:len(frame_fft)] = p[1:len(frame_fft)] * 2
        else:
            frame_fft[1:len(frame_fft) - 1] = frame_fft[1:len(frame_fft) - 1] * 2
        samplesCont += fftStepSize
        total_fft.append(frame_fft)
    global fileLengthInFrames
    fileLengthInFrames = len(total_fft)
    return total_fft

def generateSimilarityMatrix(specMatrix, lag):
    global lagInFrames
    if lag == 0:
        lag = len(specMatrix)
        lagInFrames = int(lag)
    else:
        lag = math.ceil(lag * len(specMatrix))
        lagInFrames = int(lag)
    i_cont = 0
    s_matrix = numpy.array([]).reshape(0, lag)
    while i_cont < len(specMatrix):
        j_cont = 0
        i_vector = numpy.array(specMatrix[i_cont])
        i_similarities = numpy.array([])
        while j_cont < lag and j_cont < len(specMatrix):
            j_vector = numpy.array(specMatrix[j_cont])
            i_norm = numpy.linalg.norm(i_vector, ord=1)
            j_norm = numpy.linalg.norm(j_vector, ord=1)
            dot_product = numpy.dot(i_vector, j_vector)
            cosine = dot_product / (i_norm * j_norm)
            i_similarities = numpy.append(i_similarities, cosine)
            j_cont += 1
        try:
            s_matrix = numpy.r_[s_matrix, [i_similarities]]
        except ValueError:
            print i_cont
            print j_cont
            print lag
            print len(i_similarities)
            return
        i_cont += 1
    return s_matrix

def toCsv(matrix):
    i = 0
    csvfile = open("spectrum.csv", "w")
    spectrumwriter = csv.writer(csvfile, delimiter=',',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
    while (i < len(matrix)):
        spectrumwriter.writerow(matrix[i])
        i += 1

def ccwRotation(matrix):
    reverse_matrix = matrix[::1]
    rotated_matrix = zip(*reverse_matrix)
    return rotated_matrix

def generateCheckerboardMatrix(size):
    i = 0
    inv = 1
    row = []
    for i in range(0, size):
        if i > size/2 - 1:
            inv = -1
        row.append(1 * inv)
    invertedRow = list(reversed(row))
    temp_matrix = list(row for i in range(0, size/2))
    for i in range(0, size/2):
        temp_matrix.append(invertedRow)
    c_matrix = numpy.matrix(temp_matrix)
    return c_matrix

def noveltyScore(s_matrix, kernelSize):
    c_matrix = generateCheckerboardMatrix(kernelSize)
    noveltyList = []
    # only computing the score for regions of the matrix where S and C overlap completely
    print fileLengthInFrames-kernelSize
    for i in range(0, fileLengthInFrames-kernelSize):
        i_score = 0
        for m in range(0, kernelSize):
            for n in range(0, kernelSize):
                try:
                    i_score += c_matrix.item(m,n)*s_matrix.item(i+m,i+n)
                except IndexError:
                    print "IndexError"
                    print i
                    print m
                    print n
                    return
        noveltyList.append(i_score)
    return noveltyList


def main():
    specMatrix = extractSpectrogramMatrix(sys.argv[1])
    lagPercentage = 1
    similarityMatrix = generateSimilarityMatrix(specMatrix, lagPercentage)
    noveltyList = noveltyScore(similarityMatrix, 16)
#   print noveltyList
    plt.plot(noveltyList)
#   plt.imshow(similarityMatrix, interpolation="nearest", cmap="hot", extent=(0, numpy.shape(similarityMatrix)[0],
#       0, lagPercentage*numpy.shape(similarityMatrix)[0]), origin="lower")
#   plt.colorbar()
    plt.show()

main()
