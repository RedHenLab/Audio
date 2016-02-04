import numpy.fft
from scipy.io import wavfile
import sys
import math
import csv
import matplotlib.pyplot as plt

def extractSpectrogramMatrix(path):
    fftStepSize = 1024
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
    print len(left_channel)
    while samplesCont < len(left_channel) - fftStepSize: # drops the last incomplete frame
        frame_fft = numpy.fft.fft(left_channel_norm[samplesCont:samplesCont+fftStepSize-1])
        frame_fft = frame_fft[0:math.ceil((fftStepSize+1)/2)]
        frame_fft = abs(frame_fft)
        frame_fft = frame_fft / float(fftStepSize)
        frame_fft = frame_fft**2
        if fftStepSize % 2 > 0:
            frame_fft[1:len(frame_fft)] = p[1:len(frame_fft)] * 2
        else:
            frame_fft[1:len(frame_fft) -1] = frame_fft[1:len(frame_fft) - 1] * 2
        samplesCont += fftStepSize
        total_fft.append(frame_fft)
    return total_fft

# TODO: use the lag parameter to limit height of the result matrix
def generateSimilarityMatrix(specMatrix, lag):
    if lag == 0:
        lag = len(specMatrix)
    i_cont = 0
    s_matrix = numpy.array([]).reshape(0, lag)
    while i_cont < len(specMatrix):
        j_cont = 0
        i_vector = numpy.array(specMatrix[i_cont])
        i_similarities = numpy.array([])
        while j_cont < len(specMatrix):
            j_vector = numpy.array(specMatrix[j_cont])
            i_norm = numpy.linalg.norm(i_vector, ord=1)
            j_norm = numpy.linalg.norm(j_vector, ord=1)
            dot_product = numpy.dot(i_vector, j_vector)
            cosine = dot_product / (i_norm * j_norm)
            i_similarities = numpy.append(i_similarities, cosine)
            j_cont += 1
        s_matrix = numpy.r_[s_matrix, [i_similarities]]
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

def main():
    print "spectrum generation..."
    specMatrix = extractSpectrogramMatrix(sys.argv[1])
    print "done."
    print len(specMatrix)
    similarityMatrix = generateSimilarityMatrix(specMatrix, 0)
    print len(similarityMatrix)
    plt.imshow(similarityMatrix, interpolation="nearest", cmap="hot", extent=(0, numpy.shape(similarityMatrix)[0], 0,
        numpy.shape(similarityMatrix)[0]))
    plt.colorbar()
    plt.show()



main()
