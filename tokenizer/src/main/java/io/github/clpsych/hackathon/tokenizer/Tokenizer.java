package io.github.clpsych.hackathon.tokenizer;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Reader;
import java.io.Writer;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import cmu.arktweetnlp.Twokenize;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.base.Joiner;

public class Tokenizer {
	public static ObjectMapper mapper = new ObjectMapper();
	

  public static void tokenizeTweets(Reader in, Writer out) throws JsonParseException, IOException {
	JsonParser parser = mapper.getJsonFactory().createJsonParser(in);
	
	while (parser.nextToken() != null) {
		Map<String, Object> tweet = parser.readValueAs(HashMap.class);
		String text = (String) tweet.get("text");
		List<String> tokenized = Twokenize.tokenize(text);
		String joined = Joiner.on(" ").join(tokenized);
		tweet.put("tokenized_text", joined);
		mapper.writeValue(out, tweet);
	}
  }
  
  public static void main(String[] args) throws JsonParseException, FileNotFoundException, IOException {
	final Path inRoot = new File(args[0]).toPath();
	final Path outRoot = new File(args[1]).toPath();
    Files.walkFileTree(inRoot, new SimpleFileVisitor<Path>() {
    	@Override
    	public FileVisitResult visitFile(Path file, BasicFileAttributes attrs)
    			throws IOException {
    		FileReader in = new FileReader(file.toFile());
    		Path outPath = outRoot.resolve(inRoot.relativize(file));
    		outPath.getParent().toFile().mkdirs();
    		FileWriter out = new FileWriter(outPath.toFile());
    		tokenizeTweets(in, out);
    		in.close();
    		out.close();
    		return FileVisitResult.CONTINUE;
    	}
    });
  }
}
