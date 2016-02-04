package fr.lium.test;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

import fr.lium.spkDiarization.lib.DiarizationException;
import fr.lium.spkDiarization.lib.MainTools;
import fr.lium.spkDiarization.lib.SpkDiarizationLogger;
import fr.lium.spkDiarization.libClusteringData.ClusterSet;
import fr.lium.spkDiarization.libFeature.AudioFeatureSet;
import fr.lium.spkDiarization.libMatrix.MatrixIO;
import fr.lium.spkDiarization.libMatrix.MatrixRectangular;
import fr.lium.spkDiarization.libMatrix.MatrixRowVector;
import fr.lium.spkDiarization.libMatrix.MatrixSquare;
import fr.lium.spkDiarization.libMatrix.MatrixSymmetric;
import fr.lium.spkDiarization.libModel.Distance;
import fr.lium.spkDiarization.libModel.gaussian.GMM;
import fr.lium.spkDiarization.libModel.gaussian.GMMArrayList;
import fr.lium.spkDiarization.libModel.ivector.EigenFactorRadialList;
import fr.lium.spkDiarization.libModel.ivector.EigenFactorRadialNormalizationFactory;
import fr.lium.spkDiarization.libModel.ivector.IVectorArrayList;
import fr.lium.spkDiarization.libModel.ivector.TotalVariability;
import fr.lium.spkDiarization.parameter.Parameter;

/**
 * The Class testIVector.
 */
public class testIVector {

	/** The Constant logger. */
	private final static Logger logger = Logger.getLogger(testIVector.class.getName());

	/**
	 * Test det.
	 * 
	 * @param parameter the parameter
	 * @throws IOException Signals that an I/O exception has occurred.
	 * @throws DiarizationException the diarization exception
	 */
	static public void testDet(Parameter parameter) throws IOException, DiarizationException {

		MatrixSymmetric covariance = MainTools.readMahanalonisCovarianceMatrix(parameter);

		covariance.debug();

		logger.info("ejmf det lib:" + Math.log(covariance.determinant()));
		logger.info("ejmf det chol LLt:" + covariance.choleskyDetLLt());
		// logger.info("ejmf det chol LLt2:"+covariance.choleskyDetLLt2());
		// logger.info("ejmf det chol LDLt:"+covariance.choleskyDetLDLt());
		logger.info("ejmf det chol manual:" + covariance.choleskyDetManual());
		// logger.info("jama det chol manual:"+covariance.choleskyLLtJamaManual());

		MatrixSymmetric t = new MatrixSymmetric(4);
		/*
		 * t.set(0, 1, 1); t.set(0, 2, 2); t.set(0, 3, 3); t.set(1, 2, 4); t.set(2, 3, 5);
		 */
		for (int i = 0; i < 4; i++) {
			t.set(i, i, 1.0);
		}
		t.debug();
		logger.info("ejmf det lib:" + Math.log(t.determinant()));
		logger.info("ejmf det chol LLt:" + t.choleskyDetLLt());
		// logger.info("ejmf det chol LLt2:"+t.choleskyDetLLt2());
		// logger.info("ejmf det chol LDLt:"+t.choleskyDetLDLt());
		logger.info("ejmf det chol manual:" + t.choleskyDetManual());
		// logger.info("jama det chol manual:"+t.choleskyLLtJamaManual());
	}

	/**
	 * Test matrix u.
	 * 
	 * @param clusterSet the cluster set
	 * @param featureSet the feature set
	 * @param parameter the parameter
	 * @throws FileNotFoundException the file not found exception
	 * @throws IOException Signals that an I/O exception has occurred.
	 * @throws DiarizationException the diarization exception
	 * @throws SAXException the sAX exception
	 * @throws ParserConfigurationException the parser configuration exception
	 */
	static public void testMatrixU(ClusterSet clusterSet, AudioFeatureSet featureSet, Parameter parameter) throws FileNotFoundException, IOException, DiarizationException, SAXException, ParserConfigurationException {
		GMMArrayList gmmList = MainTools.readGMMContainer(parameter);
		GMM ubm = gmmList.get(0);

		// RectMatrix matrixU = MatrixIO.readRectMatrix("./total.mat.txt", false);
		// TotalVariability totalFactorFactory = new TotalVariability(ubm, matrixU);

		TotalVariability totalFactorFactory = new TotalVariability(ubm, 50);
		totalFactorFactory.computeStatistics(clusterSet, featureSet, false);

		MatrixRectangular U = totalFactorFactory.trainTotalVariabilityMatrix(1, "totalVariability");
		MatrixIO.writeMatrix(U, "U_final.mat.txt", false);
	}

	/**
	 * Test4.
	 * 
	 * @param clusterSet the cluster set
	 * @param featureSet the feature set
	 * @param parameter the parameter
	 * @throws DiarizationException the diarization exception
	 * @throws IOException Signals that an I/O exception has occurred.
	 * @throws SAXException the sAX exception
	 * @throws ParserConfigurationException the parser configuration exception
	 * @throws ClassNotFoundException the class not found exception
	 */
	static public void test4(ClusterSet clusterSet, AudioFeatureSet featureSet, Parameter parameter) throws DiarizationException, IOException, SAXException, ParserConfigurationException, ClassNotFoundException {
		GMMArrayList gmmList = MainTools.readGMMContainer(parameter);
		GMM ubm = gmmList.get(0);

		MatrixRectangular matrixU = MatrixIO.readRectMatrix("./total.mat.txt", false);
		matrixU.toString();

		TotalVariability totalFactorFactory = new TotalVariability(ubm, matrixU);
		totalFactorFactory.computeStatistics(clusterSet, featureSet, false);
		IVectorArrayList iVectorList = totalFactorFactory.trainIVector();
		double d = Distance.iVectorEuclidean(iVectorList.get(0), iVectorList.get(1));
		// iVectorList.get(0).debug();
		// iVectorList.get(1).debug();
		logger.info("distance eucli: " + d);

		EigenFactorRadialList normalization = MainTools.readEigenFactorRadialNormalization(parameter);
		// normalization.debug();
		logger.info("number of iteration in normalisation: " + normalization.size());
		IVectorArrayList normalizedIVectorList = EigenFactorRadialNormalizationFactory.applied(iVectorList, normalization);
		MatrixSymmetric covariance = MainTools.readMahanalonisCovarianceMatrix(parameter);
		// covariance.debug();
		// normalizedIVectorList.get(0).debug();
		// normalizedIVectorList.get(1).debug();

		d = Distance.iVectorMahalanobis(normalizedIVectorList.get(0), normalizedIVectorList.get(1), covariance.invert());
		logger.info("distance mahana norm : " + d);

	}

	/**
	 * Test3.
	 * 
	 * @param clusterSet the cluster set
	 * @param featureSet the feature set
	 * @param parameter the parameter
	 * @throws DiarizationException the diarization exception
	 * @throws IOException Signals that an I/O exception has occurred.
	 * @throws SAXException the sAX exception
	 * @throws ParserConfigurationException the parser configuration exception
	 * @throws ClassNotFoundException the class not found exception
	 */
	static public void test3(ClusterSet clusterSet, AudioFeatureSet featureSet, Parameter parameter) throws DiarizationException, IOException, SAXException, ParserConfigurationException, ClassNotFoundException {
		GMMArrayList gmmList = MainTools.readGMMContainer(parameter);
		GMM ubm = gmmList.get(0);

		MatrixRectangular matrixU = MatrixIO.readRectMatrix("./total.mat.txt", false);
		matrixU.toString();

		TotalVariability totalFactorFactory = new TotalVariability(ubm, matrixU);
		totalFactorFactory.computeStatistics(clusterSet, featureSet, false);
		IVectorArrayList iVectorList = totalFactorFactory.trainIVector();

		if (SpkDiarizationLogger.DEBUG) iVectorList.get(0).debug();
		if (SpkDiarizationLogger.DEBUG) iVectorList.get(1).debug();

		double d = Distance.iVectorEuclidean(iVectorList.get(0), iVectorList.get(1));
		logger.info("distance eucli: " + d);

		parameter.getSeparator();
		MatrixSymmetric cov = MatrixIO.readMatrixSymmetric("./intra_covInv.mat", false);
// cov.debug();
		d = Distance.iVectorMahalanobis(iVectorList.get(0), iVectorList.get(1), cov);
		logger.info("distance mahana RUBY cov Inv: " + d);
		parameter.getSeparator();

		cov = MatrixIO.readMatrixSymmetric("./intra_cov.mat", false).invert();
// cov.debug();
		d = Distance.iVectorMahalanobis(iVectorList.get(0), iVectorList.get(1), cov);
		logger.info("distance mahana RUBY cov : " + d);
		parameter.getSeparator();

		MatrixSymmetric covariance = MatrixIO.readMatrixSymmetric("./train_covariance.xml", false).invert();
// covariance.debug();
		d = Distance.iVectorMahalanobis(iVectorList.get(0), iVectorList.get(1), covariance);
		logger.info("distance mahana train_covariance.xml: " + d);
		parameter.getSeparator();

		covariance = MatrixIO.readMatrixSymmetric("./train_MeanOfSpeakerCovariance.xml", false).invert();
// covariance.debug();
		d = Distance.iVectorMahalanobis(iVectorList.get(0), iVectorList.get(1), covariance);
		logger.info("distance mahana train_MeanOfSpeakerCovariance.xml: " + d);

		covariance = MatrixIO.readMatrixSymmetric("./train_cov_covariance.xml", false).invert();
// covariance.debug();
		d = Distance.iVectorMahalanobis(iVectorList.get(0), iVectorList.get(1), covariance);
		logger.info("distance mahana train_cov_covariance.xml: " + d);
		parameter.getSeparator();

		covariance = MatrixIO.readMatrixSymmetric("./train_cov_MeanOfSpeakerCovariance.xml", false).invert();
// covariance.debug();
		d = Distance.iVectorMahalanobis(iVectorList.get(0), iVectorList.get(1), covariance);
		logger.info("distance mahana train_cov_MeanOfSpeakerCovariance.xml: " + d);

		for (int i = 1; i <= 1; i++) {
			parameter.getSeparator();
			EigenFactorRadialList normalizationW = EigenFactorRadialList.readBinary("x.256.50.repere.isc" + i + ".xml");
			// normalizationW.debug();
			IVectorArrayList normalizedIVectorList = EigenFactorRadialNormalizationFactory.applied(iVectorList, normalizationW);
			covariance = MatrixIO.readMatrixSymmetric("./train_cov_MeanOfSpeakerCovariance.norm" + i + ".xml", false).invert();
			// covariance.debug();
			if (SpkDiarizationLogger.DEBUG) normalizedIVectorList.get(0).debug();
			d = Distance.iVectorMahalanobis(normalizedIVectorList.get(0), normalizedIVectorList.get(1), covariance);
			logger.info("distance mahana norm" + i + " + train_cov_MeanOfSpeakerCovariance.norm" + i + ".xml: " + d);

		}
		int i = 1;
		MatrixRowVector mean = MatrixIO.readMatrixVector("./norm" + i + "_mean.txt", false);
		MatrixSquare norm1_total_cov = MatrixIO.readMatrixSquare("./norm" + i + "_total_cov.txt", false);
		IVectorArrayList normalizedIVectorList1 = new IVectorArrayList();
		EigenFactorRadialNormalizationFactory.applie(iVectorList, normalizedIVectorList1, mean, norm1_total_cov);
		cov = MatrixIO.readMatrixSymmetric("./norm" + i + "_intra_cov.txt", false);
		d = Distance.iVectorMahalanobis(normalizedIVectorList1.get(0), normalizedIVectorList1.get(1), cov);
		logger.info("distance mahana norm RUBY " + i + " : " + d);
		i++;
		mean = MatrixIO.readMatrixVector("./norm" + i + "_mean.txt", false);
		norm1_total_cov = MatrixIO.readMatrixSquare("./norm" + i + "_total_cov.txt", false);
		IVectorArrayList normalizedIVectorList2 = new IVectorArrayList();
		EigenFactorRadialNormalizationFactory.applie(normalizedIVectorList1, normalizedIVectorList2, mean, norm1_total_cov);
		cov = MatrixIO.readMatrixSymmetric("./norm" + i + "_intra_cov.txt", false);
		if (SpkDiarizationLogger.DEBUG) normalizedIVectorList2.get(0).debug();
		d = Distance.iVectorMahalanobis(normalizedIVectorList2.get(0), normalizedIVectorList2.get(1), cov);
		logger.info("distance mahana norm RUBY " + i + " : " + d);

	}

	/**
	 * Test2.
	 * 
	 * @param clusterSet the cluster set
	 * @param featureSet the feature set
	 * @param parameter the parameter
	 * @throws DiarizationException the diarization exception
	 * @throws IOException Signals that an I/O exception has occurred.
	 * @throws SAXException the sAX exception
	 * @throws ParserConfigurationException the parser configuration exception
	 */
	static public void test2(ClusterSet clusterSet, AudioFeatureSet featureSet, Parameter parameter) throws DiarizationException, IOException, SAXException, ParserConfigurationException {
		new ClusterSet();
		GMMArrayList gmmList = MainTools.readGMMContainer(parameter);
		GMM ubm = gmmList.get(0);

		MatrixRectangular matrixU = MatrixIO.readRectMatrix("./total.mat.txt", false);
		matrixU.toString();

		TotalVariability totalFactorFactory = new TotalVariability(ubm, matrixU);
		totalFactorFactory.computeStatistics(clusterSet, featureSet, false);
		IVectorArrayList iVectorList = totalFactorFactory.trainIVector();

		// InterSessionCompensation normalizationW = InterSessionCompensation.readInterSessionCompensation("interSessionCompensation.xml");
		// normalizationW.debug();

		// IVectorArrayList normalizedIVectorList = TotalFactorFactory.appliedInterSessionCompensation(iVectorList, normalizationW);

		// Matrix At = TotalFactorFactory.computeWCCNNoramizationMatrix();
		// TotalFactorFactory.normalizeTestIVector(iVectorList, At);

		// SymmetricMatrix distance = new SymmetricMatrix(iVectorList.size());
		// SymmetricMatrix covInv = normalizationW.getGlobalInvertCovariance();
		// SymmetricMatrix covInv = SymmetricMatrix.read("meanCov.xml").invert();

		/* cov.debug(); */
		iVectorList.get(0).debug();
		iVectorList.get(1).debug();

		double d = Distance.iVectorEuclidean(iVectorList.get(0), iVectorList.get(1));
		logger.info("distance eucli: " + d);

		MatrixSymmetric cov = MatrixIO.readMatrixSymmetric("./intra_cov.mat", false);
		d = Distance.iVectorMahalanobis(iVectorList.get(0), iVectorList.get(1), cov);
		logger.info("distance mahana: " + d);

		/*
		 * DoubleVector mean = MatrixFactory.matrix2DoubleVector(MatrixIO.readJamaMatrix("./norm1_mean.txt", false)); FullGaussian fg = new FullGaussian(mean.getDimension()); fg.initialize(); for(int i = 0; i < mean.getDimension(); i++) {
		 * fg.setMean(i, mean.get(i)); fg.setCovariance(i, i, 1.0); } fg.computeInvertCovariance(); Matrix total_cov = MatrixIO.readJamaMatrix("./norm1_total_cov.txt", false); InterSessionCompensation normalizationW = new InterSessionCompensation();
		 * normalizationW.add(fg, total_cov); DoubleVector mean2 = MatrixFactory.matrix2DoubleVector(MatrixIO.readJamaMatrix("./norm2_mean.txt", false)); FullGaussian fg2 = new FullGaussian(mean2.getDimension()); fg2.initialize(); for(int i = 0; i <
		 * mean2.getDimension(); i++) { fg2.setMean(i, mean2.get(i)); fg2.setCovariance(i, i, 1.0); } fg2.computeInvertCovariance(); Matrix total_cov2 = MatrixIO.readJamaMatrix("./norm2_total_cov.txt", false); normalizationW.add(fg2, total_cov2);
		 * normalizationW.debug();
		 */

		/*
		 * IVectorArrayList normalizedIVectorList = new IVectorArrayList(); TotalFactorFactory.applieInterSessionCompensation(iVectorList, normalizedIVectorList, normalizationW.getMean(0), normalizationW.getT(0)); cov =
		 * MatrixFactory.matrix2SymmetricMatrix(MatrixIO.readJamaMatrix("./norm1_intra_cov.txt", false)); d = Distance.iVectorMahalanobis(normalizedIVectorList.get(0), normalizedIVectorList.get(1), cov); logger.info("distance norm1 mahana: "+d);
		 * IVectorArrayList normalizedIVectorList2 = new IVectorArrayList(); TotalFactorFactory.applieInterSessionCompensation(normalizedIVectorList, normalizedIVectorList2, normalizationW.getMean(1), normalizationW.getT(1));
		 */

		/*
		 * IVectorArrayList normalizedIVectorList2 = TotalFactorFactory.appliedInterSessionCompensation(iVectorList, normalizationW); cov = MatrixFactory.matrix2SymmetricMatrix(MatrixIO.readJamaMatrix("./norm2_intra_cov.txt", false)); d =
		 * Distance.iVectorMahalanobis(normalizedIVectorList2.get(0), normalizedIVectorList2.get(1), cov); logger.info("distance norm2 mahana: "+d);
		 */
		/*
		 * Matrix norm1_mean = MatrixIO.readJamaMatrix("./norm1_mean.txt", false); DoubleVector mean = MatrixFactory.matrix2DoubleVector(norm1_mean); Matrix norm1_total_cov = MatrixIO.readJamaMatrix("./norm1_total_cov.txt", false); IVectorArrayList
		 * normalizedIVectorList = new IVectorArrayList(); TotalFactorFactory.applieInterSessionCompensation(iVectorList, normalizedIVectorList, mean, norm1_total_cov); normalizedIVectorList.get(0).debug(); normalizedIVectorList.get(1).debug();
		 * intra_cov = MatrixIO.readJamaMatrix("./norm1_intra_cov.txt", false); cov = MatrixFactory.matrix2SymmetricMatrix(intra_cov); d = Distance.iVectorMahalanobis(normalizedIVectorList.get(0), normalizedIVectorList.get(1), cov);
		 * logger.info("distance norm1 mahana: "+d); Matrix norm2_mean = MatrixIO.readJamaMatrix("./norm2_mean.txt", false); mean = MatrixFactory.matrix2DoubleVector(norm2_mean); Matrix norm2_total_cov =
		 * MatrixIO.readJamaMatrix("./norm2_total_cov.txt", false); IVectorArrayList normalizedIVectorList2 = new IVectorArrayList(); TotalFactorFactory.applieInterSessionCompensation(normalizedIVectorList, normalizedIVectorList2, mean,
		 * norm2_total_cov); normalizedIVectorList.get(0).debug(); normalizedIVectorList.get(1).debug(); intra_cov = MatrixIO.readJamaMatrix("./norm2_intra_cov.txt", false); cov = MatrixFactory.matrix2SymmetricMatrix(intra_cov); d =
		 * Distance.iVectorMahalanobis(normalizedIVectorList2.get(0), normalizedIVectorList2.get(1), cov); logger.info("distance norm2 mahana: "+d);
		 */
	}

	/**
	 * Test1.
	 * 
	 * @param clusterSet the cluster set
	 * @param featureSet the feature set
	 * @param parameter the parameter
	 * @throws FileNotFoundException the file not found exception
	 * @throws IOException Signals that an I/O exception has occurred.
	 * @throws DiarizationException the diarization exception
	 * @throws SAXException the sAX exception
	 * @throws ParserConfigurationException the parser configuration exception
	 */
	static public void test1(ClusterSet clusterSet, AudioFeatureSet featureSet, Parameter parameter) throws FileNotFoundException, IOException, DiarizationException, SAXException, ParserConfigurationException {
		MatrixRectangular matrixU = MatrixIO.readRectMatrix("./total.mat.txt", false);
		matrixU.toString();

		// Compute Model
		logger.info("read GMM");
		GMMArrayList gmmList = MainTools.readGMMContainer(parameter);
		logger.info("read GMM done size:" + gmmList.size());
		GMM ubm = gmmList.get(0);

		TotalVariability totalFactorFactory = new TotalVariability(ubm, matrixU);
		totalFactorFactory.computeStatistics(clusterSet, featureSet, false);
		totalFactorFactory.trainIVector();
		EigenFactorRadialList normalization = new EigenFactorRadialList();

		// ArrayList<IVector> trainIVectorList = loadIVector("x.256.50.repere.txt");

		// totalFactorFactory.trainInterSessionCompensation(trainIVectorList, normalization);

		EigenFactorRadialList.writeBinary(normalization, "normalizationW.xml");

		/*
		 * SymmetricMatrix dist = new SymmetricMatrix(5); ExhaustiveClustering bt = new ExhaustiveClustering(dist, 110); bt.backtrack();
		 */

		/*
		 * GRBEnv env = new GRBEnv("mip1.log"); GRBModel model = new GRBModel(env); // Create variables GRBVar x = model.addVar(0.0, 1.0, 0.0, GRB.BINARY, "x"); GRBVar y = model.addVar(0.0, 1.0, 0.0, GRB.BINARY, "y"); GRBVar z = model.addVar(0.0,
		 * 1.0, 0.0, GRB.BINARY, "z"); // Integrate new variables model.update(); // Set objective: maximize x + y + 2 z GRBLinExpr expr = new GRBLinExpr(); expr.addTerm(1.0, x); expr.addTerm(1.0, y); expr.addTerm(2.0, z); model.setObjective(expr,
		 * GRB.MAXIMIZE); // Add constraint: x + 2 y + 3 z <= 4 expr = new GRBLinExpr(); expr.addTerm(1.0, x); expr.addTerm(2.0, y); expr.addTerm(3.0, z); model.addConstr(expr, GRB.LESS_EQUAL, 4.0, "c0"); // Add constraint: x + y >= 1 expr = new
		 * GRBLinExpr(); expr.addTerm(1.0, x); expr.addTerm(1.0, y); model.addConstr(expr, GRB.GREATER_EQUAL, 1.0, "c1"); // Optimize model model.optimize(); System.out.println(x.get(GRB.StringAttr.VarName) + " " +x.get(GRB.DoubleAttr.X));
		 * System.out.println(y.get(GRB.StringAttr.VarName) + " " +y.get(GRB.DoubleAttr.X)); System.out.println(z.get(GRB.StringAttr.VarName) + " " +z.get(GRB.DoubleAttr.X)); System.out.println("Obj: " + model.get(GRB.DoubleAttr.ObjVal)); // Dispose
		 * of model and environment model.dispose(); env.dispose();
		 */

	}

	/**
	 * The main method.
	 * 
	 * @param args the arguments
	 * @throws Exception the exception
	 */
	public static void main(String[] args) throws Exception {
		try {
			SpkDiarizationLogger.setup();
			Parameter parameter = MainTools.getParameters(args);
			info(parameter, "test");
			if (parameter.show.isEmpty() == false) {
				// clusters
				ClusterSet clusterSet = MainTools.readClusterSet(parameter);
				// Features
				AudioFeatureSet featureSet = MainTools.readFeatureSet(parameter, clusterSet);
				featureSet.setCurrentShow(clusterSet.getFirstCluster().firstSegment().getShowName());

				// testMatrixU(clusterSet, featureSet, parameter);
				testDet(parameter);
			}
		} catch (DiarizationException e) {
			logger.log(Level.SEVERE, "error \t exception ", e);
			e.printStackTrace();
		}
	}

	/**
	 * Info.
	 * 
	 * @param parameter the parameter
	 * @param program the program
	 * @throws IllegalArgumentException the illegal argument exception
	 * @throws IllegalAccessException the illegal access exception
	 * @throws InvocationTargetException the invocation target exception
	 */
	public static void info(Parameter parameter, String program) throws IllegalArgumentException, IllegalAccessException, InvocationTargetException {
		if (parameter.help) {
			logger.config(parameter.getSeparator2());
			logger.config("info[program] \t name = " + program);
			parameter.getSeparator();
			parameter.logShow();

			parameter.getParameterInputFeature().logAll(); // fInMask
			logger.config(parameter.getSeparator());
			parameter.getParameterSegmentationInputFile().logAll();
			parameter.getParameterSegmentationOutputFile().logAll(); // sOutMask
			logger.config(parameter.getSeparator());

			parameter.getParameterModelSetInputFile().logAll(); // tInMask

			logger.config(parameter.getSeparator());
			parameter.getParameterNormlization().logAll();
			logger.config(parameter.getSeparator());

			logger.config(parameter.getSeparator());
		}
	}

}
