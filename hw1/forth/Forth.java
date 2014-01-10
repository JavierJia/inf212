package forth;

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
import java.util.Stack;

public class Forth {
	static HashMap<String, Object> heap = new HashMap<String, Object>();
	static Stack<Object> stack = new Stack<Object>();

	public static void main(String[] argv) throws IOException {
		stack.push(argv[0]);
		loadFile();
		countFreqs();
		sortMap();
		outputFreq();
	}

	private static void loadFile() throws IOException {
		// read all strings onto stack.
		stack.push(new String(
				Files.readAllBytes(Paths.get((String) stack.pop())))
				.toLowerCase());
	}

	@SuppressWarnings("unchecked")
	private static void countFreqs() throws IOException {
		stack.push("../stop_words.txt");
		// read the stop_words and split it into a HashSet
		stack.push(new HashSet<String>(Arrays.asList(new String(Files
				.readAllBytes(Paths.get((String) stack.pop()))).split(","))));
		heap.put("stop-word-map", stack.pop());

		// create and keep a new map inside heap
		stack.push(new HashMap<String, Integer>());
		heap.put("freq-map", stack.pop());

		// split the words
		stack.addAll(Arrays.asList(((String) stack.pop()).split("[\\W_]+")));
		while (!stack.empty()) {
			if (((HashSet<String>) heap.get("stop-word-map"))
					.contains((String) stack.peek())) {
				// stop words, pop and throw it.
				stack.pop();
			} else {
				// insert into word map
				if (((HashMap<String, Integer>) heap.get("freq-map"))
						.containsKey(stack.peek())) {
					// exist, add it.
					stack.push(((HashMap<String, Integer>) heap.get("freq-map"))
							.get(stack.peek()));
					stack.push(1);
					stack.push((Integer) stack.pop() + (Integer) stack.pop());
				} else {
					stack.push(1);
				}
				heap.put("freq-cache", stack.pop());
				((HashMap<String, Integer>) heap.get("freq-map")).put(
						(String) stack.pop(), (Integer) heap.get("freq-cache"));
			}
		}
		stack.push(heap.get("freq-map"));
	}

	@SuppressWarnings("unchecked")
	private static void sortMap() {
		stack.push(new ArrayList<Entry<String, Integer>>(
				((HashMap<String, Integer>) stack.pop()).entrySet()));
		Collections.sort((ArrayList<Entry<String, Integer>>) stack.peek(),
				new Comparator<Entry<String, Integer>>() {

					@Override
					public int compare(Entry<String, Integer> o1,
							Entry<String, Integer> o2) {
						return o1.getValue().compareTo(o2.getValue());
					}
				});
	}

	@SuppressWarnings("unchecked")
	private static void outputFreq() {
		stack.addAll(((ArrayList<Entry<String, Integer>>) stack.pop()));
		stack.push(0);
		while (!stack.empty() && ((Integer) stack.peek()) < 25) {
			heap.put("i", stack.pop());
			System.out.print(((Entry<String, Integer>) stack.peek()).getKey());
			System.out.printf(" - %d\n",
					((Entry<String, Integer>) stack.pop()).getValue());
			stack.push((Integer) heap.get("i") + 1);
		}
	}
}
