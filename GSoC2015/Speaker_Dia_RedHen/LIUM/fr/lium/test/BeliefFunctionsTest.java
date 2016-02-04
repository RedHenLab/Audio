package fr.lium.test;

import static org.junit.Assert.assertTrue;

import java.util.HashMap;

import org.junit.Test;

import fr.lium.spkDiarization.libModel.Distance;

/**
 * The Class BeliefFunctionsTest.
 * 
 * @author Vincent Jousse
 */
public class BeliefFunctionsTest {

	/**
	 * Main test.
	 */
	@Test
	public void mainTest() {

		HashMap<String, Double> hash1 = new HashMap<String, Double>();
		HashMap<String, Double> hash2 = new HashMap<String, Double>();

		hash1.put("A", new Double(0.29));
		hash1.put("_omega_", new Double(0.71));

		hash2.put("A", new Double(0.29));
		hash2.put("_omega_", new Double(0.71));

		HashMap<String, Double> result = Distance.computeBeliefFunctions(hash1, hash2);

		// {_omega_=0.5041, A=0.49589999999999995}
		System.out.println("* Checking map size, should be 2: A and _omega_");
		assertTrue(result.size() == 2);
		System.out.println(result);

		hash1.clear();

		hash1.put("B", new Double(0.9));
		hash1.put("_omega_", new Double(0.1));

		result = Distance.computeBeliefFunctions(result, hash1);

		// {_omega_=0.05041, A=0.049589999999999995, B=0.45369}
		System.out.println("* Checking map size, should be 3: A, B and _omega_");
		assertTrue(result.size() == 3);
		System.out.println(result);

		hash1.clear();
		hash1.put("A", new Double(0.5));
		hash1.put("C", new Double(0.2));
		hash1.put("_omega_", new Double(0.3));

		result = Distance.computeBeliefFunctions(result, hash1);

		// {_omega_=0.015123000000000001, A=0.06487699999999999, B=0.13610699999999998, C=0.010082}
		System.out.println("* Checking map size, should be 3: A, B, C and _omega_");
		assertTrue(result.size() == 4);
		System.out.println(result);

	}
}
