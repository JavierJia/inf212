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

public class CandyStopWordPassingByArgument {
	public static void main(String argv[]) throws IOException {
		if (argv.length < 2) {
			System.err
					.println("Usage CandyStopWordPassingByArgument <inputFile> <stopWordFile>");
			return;
		}

		ArrayList<Entry<String, Integer>> word_freqs = sort(frequency((remove_stop_word((normalize(readFile(argv)))))));
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

	private static ArrayList<String> remove_stop_word(
			ArrayList<String> arrayList) throws IOException {
		HashSet<String> stopword = new HashSet<String>(Arrays.asList(arrayList
				.get(0).split(",")));
		ArrayList<String> real_words = new ArrayList<String>();
		// skip the stopword line.
		for (int i = 1; i < arrayList.size(); ++i) {
			if (!stopword.contains(arrayList.get(i))) {
				real_words.add(arrayList.get(i));
			}
		}
		return real_words;
	}

	private static ArrayList<String> normalize(String[] allStrings) {
		ArrayList<String> normalized = new ArrayList<String>();
		normalized.add(allStrings[0]);
		normalized.addAll(Arrays.asList(allStrings[1].split("[\\W_]+")));
		return normalized;
	}

	private static String[] readFile(String[] string) throws IOException {
		// two string
		// 0 : stop word
		// 1 : file data
		return new String[] {
				new String(Files.readAllBytes(Paths.get(string[1])))
						.toLowerCase(),
				new String(Files.readAllBytes(Paths.get(string[0])))
						.toLowerCase() };
	}
}
