require "yaml"

class Hangman
  def initialize
    @counting = 6
    @dictionary = File.open("5desk.txt", "r")
    @secret_word = ""
    choosing_secret_word
    @working_word = "".rjust(@secret_word.length, "_")
    play
  end

  def play
    puts "\n#{@working_word}   -   (#{@working_word.length} letters)"
    puts "\n!!! You have #{@counting} more chances before hanging. !!!"

    until @counting == 0 || @working_word == @secret_word
      user_typing

      if @letter.match /^[a-z]$/
        comparing_and_counting
      elsif @letter == "save"
        save_game
      elsif @letter == "load"
        load_game
      elsif @letter == "exit"
        exit
      end
    end

    win_or_lose
  end  

  def choosing_secret_word
    @secret_word = @dictionary.read.split(/\n/).map! do |x| 
                    x if x.length >= 5 && x.length <= 12
                   end.shuffle[0]
  end

  def user_typing
    puts "\nType your letter: (or \"load\", \"save\", \"exit\")"
    @letter = gets.chomp.downcase

    until @letter.match /^[a-z]$|^save$|^load$|^exit$/
      puts "\nWrong input. \nPut single letter, \"load\", \"save\" or \"exit\""
      @letter = gets.chomp.downcase
    end
  end

  def comparing_and_counting
     @secret_word.each_char.with_index do |char, index|
      @working_word[index] = @letter if char == @letter 
    end

    if !@secret_word.include? @letter
      @counting -= 1 
      puts "\n!!! You have #{@counting} more chances before hanging. !!!"
    end

    puts "\n#{@working_word}"
  end

  def save_game
    Dir.mkdir('saves') unless Dir.exist? 'saves'
    puts "Name your file:"
    @file_name = gets.chomp.downcase

    until !File.exists?("saves/#{@file_name}")
      puts "\nFile with given name (#{@file_name}) already exists."
      puts "Choose another name."
      @file_name = gets.chomp.downcase
    end

    File.open("saves/#{@file_name}","w").puts YAML.dump(self)
    puts "--> GAME SAVED <--"
  end

  def load_game
    puts "Which file do you want to load ?"
    Dir.entries("saves").select { |file| puts file if file != "." && file != ".." }
    @file_to_load = gets.chomp.downcase

    until File.exist?("saves/#{@file_to_load}")
      puts "There is no such file. Give correct name."
      @file_to_load = gets.chomp.downcase
    end
    
    @loaded_game = YAML.load(File.open("saves/#{@file_to_load}"))
    puts "--> GAME LOADED <--"
    @loaded_game.play
  end

  def win_or_lose
    if @secret_word == @working_word
      puts "\nYou guessed the word !"
      play_again?
    elsif @counting == 0
      puts "\nYou hanged !"
      puts "\nSecret word was: #{@secret_word}"
      play_again?
    end
  end

  def play_again?
    puts "\nPlay again ? (Type \"Y\" or \"N\")"
    @play_again = gets.chomp.downcase

    until @play_again == "y" || @play_again == "n"
      puts "\nType \"Y\" or \"N\""
      @play_again = gets.chomp.downcase
    end

    if @play_again == "y"
      Hangman.new
    elsif @play_again == "n"
      exit
    end
  end

end

Hangman.new
