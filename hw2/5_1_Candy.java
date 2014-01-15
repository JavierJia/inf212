package candy;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map.Entry;

public class Candy {

	public static void main(String argv[]) throws IOException {

		ArrayList<Entry<String, Integer>> word_freqs = sort(frequency((remove_stop_word((normalize(readFile(argv[0])))))));
		for (int i = 0; i < word_freqs.size() && i < 25; i++) {
			System.out.println(word_freqs.get(i).getKey() + " - "
					+ word_freqs.get(i).getValue());
		}
	}

	private static ArrayList<Entry<String, Integer>> sort(
			HashMap<String, Integer> frequency) {
		ArrayList<Entry<String, Integer>> sorted = new ArrayList<Entry<String, Integer>>(
				frequency.entrySet());
		Collections.sort(sorted, new Comparator<Entry<String, Integer>>() {

			@Override
			public int compare(Entry<String, Integer> o1,
					Entry<String, Integer> o2) {
				return -o1.getValue().compareTo(o2.getValue());
			}
		});
		return sorted;
	}

	private static HashMap<String, Integer> frequency(
			ArrayList<String> arrayList) {
		HashMap<String, Integer> map = new HashMap<String, Integer>();
		for (String str : arrayList) {
			if (map.containsKey(str)) {
				map.put(str, map.get(str));
			} else {
				map.put(str, 1);
			}
		}
		return map;
	}

	private static ArrayList<String> remove_stop_word(String[] strings)
			throws IOException {
		HashSet<String> stopword = new HashSet<String>(
				Arrays.asList(new String(Files.readAllBytes(Paths
						.get("../stop_words.txt"))).toLowerCase().split(",")));
		ArrayList<String> real_words = new ArrayList<String>();
		for (String word : strings) {
			if (!stopword.contains(word)) {
				real_words.add(word);
			}
		}
		return real_words;
	}

	private static String[] normalize(String allString) {
		return allString.split("[\\W_]+");
	}

	private static String readFile(String string) throws IOException {
		return new String(Files.readAllBytes(Paths.get(string))).toLowerCase();
	}

}
