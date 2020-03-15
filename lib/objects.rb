require 'pry'

module Concerns::Findable
  
  def find_by_name(name)
    self.all.detect {|object| object.name == name}
  end
  
  def find_or_create_by_name(name)
    if self.find_by_name(name) == nil
      self.create(name)
    else
      self.find_by_name(name)
    end
  end
  
  def initialize(name)
    @name = name
    @songs = []
  end
  
  def add_song(song)
    if song.genre == nil
      song.genre = self
    end
    if !self.songs.include?(song)
      self.songs << song
    end
  end
  
end

class Song
  
  attr_accessor :name
  attr_reader :artist
  attr_reader :genre
  
  @@all = []
 
  def self.all
    @@all
  end
  
  def self.destroy_all
    @@all = []
  end
  
  def self.create(name)
    thing = self.new(name)
    thing.save
    thing
  end
  
  def save
    @@all << self
  end
  
  def initialize(name,artist=nil,genre=nil)
    @name = name
    if artist != nil
      self.artist = artist
    end
    if genre != nil
      self.genre = genre
    end
  end
  
  def genre=(genre)
    @genre = genre
    genre.add_song(self)
  end
  
  def artist=(artist)
    @artist = artist
    artist.add_song(self)
  end
  
  def self.find_by_name(name)
    self.all.detect {|object| object.name == name}
  end
  
  def self.find_or_create_by_name(name)
    if self.find_by_name(name) == nil
      self.create(name)
    else
      self.find_by_name(name)
    end
  end
  
  def self.new_from_filename(filename)
    name_array = filename.split(" - ")
    genre_name = name_array[2].split(".mp3").first
    song = Song.create(name_array[1])
    artist = Artist.find_or_create_by_name(name_array[0])
    genre = Genre.find_or_create_by_name(genre_name)
    song.artist = artist
    song.genre = genre
    song
  end
  
  def self.create_from_filename(filename)
    self.new_from_filename(filename).save
  end
  
end

class Artist
  
  extend Concerns::Findable
  
  attr_accessor :name
  attr_accessor :songs
  
  @@all = []
 
  def self.all
    @@all
  end
  
  def self.destroy_all
    @@all = []
  end
  
  def self.create(name)
    thing = self.new(name)
    thing.save
    thing
  end
  
  def save
    @@all << self
  end
  
  def initialize(name)
    @name = name
    @songs = []
  end
  
  def add_song(song)
    if song.artist == nil
      song.artist = self
    end
    if !self.songs.include?(song)
      self.songs << song
    end
  end
  
  def genres
    genres = []
    @songs.each do |song|
      if !genres.include?(song.genre)
        genres << song.genre
      end
    end
    genres
  end
  
end

class Genre
  
  extend Concerns::Findable
  
  attr_accessor :name
  attr_accessor :songs
  
  @@all = []
 
  def self.all
    @@all
  end
  
  def self.destroy_all
    @@all = []
  end
  
  def self.create(name)
    thing = self.new(name)
    thing.save
    thing
  end
  
  def save
    @@all << self
  end
  
  def initialize(name)
    @name = name
    @songs = []
  end
  
  def add_song(song)
    if song.genre == nil
      song.genre = self
    end
    if !self.songs.include?(song)
      self.songs << song
    end
  end
  
  def artists
    artists = []
    @songs.each do |song|
      if !artists.include?(song.artist)
        artists << song.artist
      end
    end
    artists
  end
  
end

class MusicImporter
  
  attr_reader :path
  
  def initialize(path)
    @path = path
  end
  
  def files
    Dir.glob("#{@path}/*.mp3").collect {|path| path.split("/").last}
  end
  
  def import
    self.files.each {|filename| Song.create_from_filename(filename)}
  end
end

class MusicLibraryController
  
  def initialize(path='./db/mp3s')
    MusicImporter.new(path).import
  end
  
  def song_sort
    Song.all.uniq.sort_by {|song| song.name}
  end
  
  def list_songs
    count = 1
    song_sort.each do |song|
      puts "#{count}. #{song.artist.name} - #{song.name} - #{song.genre.name}"
      count += 1
    end
  end
  
  def list_array(array)
    count = 1
    array.each do |item|
      puts "#{count}. #{item}"
      count += 1
    end
  end
  
  def list_artists
    list_array(Artist.all.collect {|artist| artist.name}.sort)
  end
  
  def list_genres
    list_array(Genre.all.collect {|genre| genre.name}.sort)
  end
  
  def list_songs_by_artist
    puts "Please enter the name of an artist:"
    input = gets.strip
    array = Song.all.select {|song| song.artist.name == input}.sort_by {|song| song.name}.uniq
    count = 1
    array.each do |song|
      puts "#{count}. #{song.name} - #{song.genre.name}"
      count += 1
    end
  end
  
  def list_songs_by_genre
    puts "Please enter the name of a genre:"
    input = gets.strip
    array = Song.all.select {|song| song.genre.name == input}.sort_by {|song| song.name}.uniq
    count = 1
    array.each do |song|
      puts "#{count}. #{song.artist.name} - #{song.name}"
      count += 1
    end
  end
  
  def play_song
    puts "Which song number would you like to play?"
    input = gets.strip.to_i
    if input.between?(1,song_sort.count)
      puts "Playing #{song_sort[input - 1].name} by #{song_sort[input - 1].artist.name}"
    end
  end
  
  def call
    puts "Welcome to your music library!"
    puts "To list all of your songs, enter 'list songs'."
    puts "To list all of the artists in your library, enter 'list artists'."
    puts "To list all of the genres in your library, enter 'list genres'."
    puts "To list all of the songs by a particular artist, enter 'list artist'."
    puts "To list all of the songs of a particular genre, enter 'list genre'."
    puts "To play a song, enter 'play song'."
    puts "To quit, type 'exit'."
    puts "What would you like to do?"
    choice = gets.strip
    if choice == "list songs"
      list_songs
      elsif choice == "list artists"
      list_artists
      elsif choice == "list genres"
      list_genres
      elsif choice == "list artist"
      list_songs_by_artist
      elsif choice == "list genre"
      list_songs_by_genre
      elsif choice == "play song"
      play_song
      elsif choice == "exit"
      return
    else
      call
    end
  end
  
end