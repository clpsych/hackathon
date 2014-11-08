package io.github.clpsych.hackathon.tokenizer;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Reader;
import java.io.Writer;
import java.io.BufferedWriter;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import cmu.arktweetnlp.Tagger;
import cmu.arktweetnlp.Tagger.TaggedToken;
import cmu.arktweetnlp.Twokenize;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.base.Joiner;

public class Tokenizer {
	public static ObjectMapper mapper = new ObjectMapper();
	public static Tagger tagger;

	public static boolean doTokenize = true;
	public static boolean doTag = true;

	public static BufferedWriter bw;

  public static void tokenizeTweets(Reader in, PrintWriter out) throws JsonParseException, IOException {
	JsonParser parser = mapper.getJsonFactory().createJsonParser(in);

	while (parser.nextToken() != null) {
		Map<String, Object> tweet = parser.readValueAs(HashMap.class);
		String text = (String) tweet.get("text");

		if (doTokenize) {

			try {
				List<String> tokenized = Twokenize.tokenize(text);

				if (tokenized.size()>0)
				{
					tweet.put("tokenized_text", Joiner.on(" ").join(tokenized));
				} else {
					tweet.put("tokenized_text", "NO_OUTPUT_PRODUCED");
				}
			} catch (Throwable t) // yeah, typically you don't want to do this...
			{
				bw.write(tweet.get("id").toString());
				bw.newLine();
			}
		}

		if (doTag) {

			try {

				List<TaggedToken> taggedTokens = tagger.tokenizeAndTag(text);
				List<String> taggedTokenStrings = new ArrayList<String>(taggedTokens.size());
				for (TaggedToken token : taggedTokens) {
					taggedTokenStrings.add(token.token + "/" + token.tag);
				}

				if (taggedTokenStrings.size() > 0) {
					tweet.put("tagged_text", Joiner.on(" ").join(taggedTokenStrings));
				} else {
					tweet.put("tagged_text", "NO_OUTPUT_PRODUCED");
				}
			} catch (Throwable t) // yeah, typically you don't want to do this...
			{
				bw.write(tweet.get("id").toString());
				bw.newLine();
			}
		}
		out.println(mapper.writeValueAsString(tweet));

	}
}



  public static void main(String[] args) throws JsonParseException, FileNotFoundException, IOException {
	final Path inRoot = new File(args[0]).toPath();
	final Path outRoot = new File(args[1]).toPath();
	tagger = new Tagger();
	String modelFile = "/cmu/arktweetnlp/model.20120919";
	if (args.length > 2) {
		modelFile = args[2];
	}

	bw = new BufferedWriter(new FileWriter("ignored_tweet_ids.txt"));

	tagger.loadModel(modelFile);
    Files.walkFileTree(inRoot, new SimpleFileVisitor<Path>() {
    	@Override
    	public FileVisitResult visitFile(Path file, BasicFileAttributes attrs)
    			throws IOException {
    		FileReader in = new FileReader(file.toFile());
    		Path outPath = outRoot.resolve(inRoot.relativize(file));
    		System.out.println(file + " -> " + outPath);
    		outPath.getParent().toFile().mkdirs();
    		PrintWriter out = new PrintWriter(new FileWriter(outPath.toFile()));
    		tokenizeTweets(in, out);
    		in.close();
    		out.close();
    		return FileVisitResult.CONTINUE;
    	}
    });

		try {bw.close();}
		catch (IOException ioe) {}

  }
}
