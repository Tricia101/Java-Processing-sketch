import rita.*; //<>//
import controlP5.*;
import java.util.List;
import java.util.ListIterator;
import java.util.Set;
import java.util.HashSet;
import java.util.stream.Collectors;
import java.util.Arrays;

ControlP5 cp5;
Table movieLines, movieList;
String selectmovie, selectcharacter;
String selectMovieId;
Textfield myMoviefield;
Textarea resultArea;
Textfield myCharfield;
List<MovieMarker> originalList;
List<MovieMarker> workingList;
List<CharMarker> originalCharList;
List<CharMarker> workingCharList;
String dataSource = "movie_titles_metadata_header.csv";
String lineSource = "movie_lines_header.csv";
//https://www.w3schools.com/java/java_arraylist.asp
ArrayList<String> linesOfAChar = new ArrayList<String>();

void setup() {
  size(460, 540);
  originalList = createMarkerList(dataSource);
  workingList = originalList;
  
  originalCharList = createLineMarkerList(lineSource);
  workingCharList = originalCharList;

  cp5 = new ControlP5(this);
  myMoviefield = cp5.addTextfield("film").setPosition(20, 100).setSize(200, 40).setAutoClear(false)
  .setId(0);
  myCharfield = cp5.addTextfield("character").setPosition(20, 170).setSize(200, 40).setAutoClear(false)
  .setId(1);
  
  resultArea = cp5.addTextarea("txt")
                  .setPosition(135 ,285)
                  .setSize(95, 85)
                  .setFont(createFont("arial",12))
                  .setLineHeight(14)
                  .setColor(color(0))
                  .setColorBackground(color(255, 255))
               
                  ;

  
  cp5.addButton("filmsubmit").setPosition(240, 100).setSize(80, 40)
  .onRelease(new CallbackListener() {  
    public void controlEvent(CallbackEvent theEvent) {
        selectmovie = myMoviefield.getText();
        MovieMarker m = buildFilteredList(); // first movie searched
        println(m.movieName); // m.movieId
        selectMovieId = m.movieId;
      }
  });
  
   cp5.addButton("charactersubmit").setPosition(240, 170).setSize(80, 40)
  .onRelease(new CallbackListener() {  
    public void controlEvent(CallbackEvent theEvent) {
        selectcharacter = myCharfield.getText().toUpperCase();
        CharMarker m = buildFilteredCharList(); // first char searched
        println(m.CharacterName); // MovieLine
        
        workingCharList = workingCharList.stream()
        .filter(c -> c.isMatched(m.CharacterName))
        .collect(Collectors.toList()); // filter character
        String line = ""; 
        int numOflinesWithPrp = 0;
        ListIterator<CharMarker> lines = workingCharList.listIterator();
        while (lines.hasNext()) {
          line = lines.next().MovieLine;
          linesOfAChar.add(line);
          
          String [] partsOfSpeech = RiTa.pos(line);
          if (Arrays.asList(partsOfSpeech).contains("prp")) {
            numOflinesWithPrp++;
          }
        }
        println(( (float)numOflinesWithPrp / (float)linesOfAChar.size() * 100)  + " %");
        resultArea.append(( (float)numOflinesWithPrp / (float)linesOfAChar.size() * 100)  + " %");
      }
  });
  
  

  //println("Movie Line:");
  //println(theLine);
  //println(partsOfSpeech);
}

MovieMarker buildFilteredList() {
  MovieMarker movie;
  if (selectmovie != null && !selectmovie.isEmpty()) 
  {
    workingList = originalList; // reset workingList
    workingList = workingList.stream()
    .filter(m -> m.isMatched(selectmovie))
    .collect(Collectors.toList());
  
    println("filter : " + workingList.size());
    return movie = (workingList.size() != 0 ? workingList.get(0) : null);
  }
  return null;
}

class MovieMarker {
  String movieId;
  String movieName;
  
  public MovieMarker(String movieId,String movieName) {
    this.movieId = movieId;
    this.movieName = movieName;
  }
  boolean isMatched(String searchMovie) {
    return( this.movieName.contains(searchMovie) ); // make the filter work wiht year range
  }
}

CharMarker buildFilteredCharList() {
  CharMarker character;
  if (selectcharacter != null && !selectcharacter.isEmpty() 
  && selectMovieId != null && !selectMovieId.isEmpty()) 
  {
    println(selectMovieId);
    workingCharList = originalCharList; // reset workingList
    workingCharList = workingCharList.stream()
    .filter(m -> m.IDMatched(selectMovieId))
    .collect(Collectors.toList()); // filter MovieId
    workingCharList = workingCharList.stream()
    .filter(m -> m.isMatched(selectcharacter))
    .collect(Collectors.toList()); // filter character
  
    //println("filter : " + workingCharList.size());
    return character = (workingCharList.size() != 0 ? workingCharList.get(0) : null);
  }
  return null;
}

class CharMarker {
  String movieId;
  String CharacterName;
  String MovieLine;
  
  public CharMarker(String movieId,String CharacterName, String MovieLine) {
    this.movieId = movieId;
    this.CharacterName = CharacterName;
    this.MovieLine = MovieLine;
  }
  boolean isMatched(String searchChar) {
    return( this.CharacterName.contains(searchChar) ); // make the filter work wiht year range
  }
  boolean IDMatched(String searchId) {
    return( this.movieId.contains(searchId) );
  }
}

void draw()
{}

//func
// returnType funcName(paraType paraName, , ) {
//  return returnValue; }

List<MovieMarker> createMarkerList(String source) {
  Table data = loadTable(source, "header");  
  List<MovieMarker> movies = new ArrayList<MovieMarker>();
 for (TableRow row : data.rows()) {
   String movieId = row.getString("MovieID");
   String movieName = row.getString("MovieName");
   movies.add(new MovieMarker(movieId, movieName));
 }

  return movies;
}

List<CharMarker> createLineMarkerList(String linesource) {
  Table data = loadTable(linesource, "header");  
  println(data.getRowCount() + " total rows in table");
  List<CharMarker> characters = new ArrayList<CharMarker>();
  for (TableRow row : data.rows()) {
     String movieId = row.getString("MovieID");
     String CharacterName = row.getString("CharacterName");
     String movieLine = row.getString("MovieLine");
     characters.add(new CharMarker(movieId, CharacterName, movieLine));
  }

  return characters;
}
