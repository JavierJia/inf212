package ADT;
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

public class ADT {

    interface IDataStorage {
        String[] getWords();
    }

    interface IStopWordFilter {
        boolean isStopWord(String word);
    }

    interface IWordFrequencyCounter {
        void increment_counter(String word);

        ArrayList<Entry<String, Integer>> sorted();
    }

    static class DataStorageManager implements IDataStorage {

        private String[] words;

        public DataStorageManager(String path_tofile) throws IOException {
            words = new String(Files.readAllBytes(Paths.get(path_tofile)))
                    .toLowerCase().split("[\\W_]+");
        }

        @Override
        public String[] getWords() {
            return words;
        }

    }

    static class StopWordManager implements IStopWordFilter {
        HashSet<String> stopwords;

        public StopWordManager() throws IOException {
            stopwords = new HashSet<String>(Arrays.asList(new String(Files
                    .readAllBytes(Paths.get("../stop_words.txt")))
                    .toLowerCase().split(",")));
        }

        @Override
        public boolean isStopWord(String word) {
            return word.length() < 2 || stopwords.contains(word);
        }

    }

    static class WordFrequencyManager implements IWordFrequencyCounter {

        HashMap<String, Integer> counter = new HashMap<String, Integer>();

        @Override
        public void increment_counter(String word) {
            Integer freq = counter.get(word);
            if (freq == null) {
                freq = 0;
            }
            counter.put(word, freq + 1);
        }

        @Override
        public ArrayList<Entry<String, Integer>> sorted() {
            ArrayList<Entry<String, Integer>> sorted = new ArrayList<Entry<String, Integer>>(
                    counter.entrySet());
            Collections.sort(sorted, new Comparator<Entry<String, Integer>>() {

                @Override
                public int compare(Entry<String, Integer> o1,
                        Entry<String, Integer> o2) {
                    return -o1.getValue().compareTo(o2.getValue());
                }
            });
            return sorted;
        }

    }

    static class WordFrequencyController {
        IDataStorage dataStorage;
        IStopWordFilter stopFilter;
        IWordFrequencyCounter counter;

        public WordFrequencyController(String path) throws IOException {
            dataStorage = new DataStorageManager(path);
            stopFilter = new StopWordManager();
            counter = new WordFrequencyManager();
        }

        public void run() {
            for (String word : dataStorage.getWords()) {
                if (!stopFilter.isStopWord(word)) {
                    counter.increment_counter(word);
                }
            }
            for (Entry<String, Integer> entry : counter.sorted().subList(0, 25)) {
                System.out.println(entry.getKey() + " - " + entry.getValue());
            }
        }
    }

    public static void main(String argv[]) throws IOException {
        new WordFrequencyController(argv[0]).run();
    }
}

