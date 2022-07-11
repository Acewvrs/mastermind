require 'pry-byebug'

class Board
  def fill_in_guess(code, num, result) 
    code.each_with_index { | ans, ans_idx |
      if result[ans_idx] == "?" && num.to_i == ans
        correct_num_but_incorrect_position += 1
        result[ans_idx] = "O"
        break
      end
    }
  end

  def compare_guess(guess)
    result = Array.new(4, "?")
    p get_code
    correct_guesses = 0
    correct_num_but_incorrect_position = 0

    guess.split("").each_with_index { | num, idx |
      if num.to_i == @code[idx] 
        correct_guesses += 1
        if result[idx] == "O" 
          @code.each_with_index { | ans, ans_idx |
            if result[ans_idx] == "?" && num.to_i == ans
              correct_num_but_incorrect_position += 1
              result[ans_idx] = "O"
              break
            end
          }
          correct_num_but_incorrect_position -= 1
        end
        result[idx] = "O"
      elsif @code.include?(num.to_i)
        @code.each_with_index { | ans, ans_idx |
          if result[ans_idx] == "?" && num.to_i == ans
            correct_num_but_incorrect_position += 1
            result[ans_idx] = "O"
            break
          end
        }
        p get_code
      end
    }
    return correct_guesses, correct_num_but_incorrect_position
  end

  def generate_random_code
    @code.clear
    for i in 1..4 do 
      @code.push(rand(1..6))
    end
  end

  def get_code()
    @code
  end

  def set_code(code)
    @code = code
  end

  private
  def initialize
    @code = Array.new()
    #generate_random_code()
    @code = [4, 3, 2, 1]
  end
end

def compare_guess_to_given_code(code, guess)
  result = Array.new(4, "?")

  correct_guesses = 0
  correct_num_but_incorrect_position = 0

  guess.split("").each_with_index { | num, idx |
    if num.to_i == code[idx] 
      correct_guesses += 1
      if result[idx] == "O" 
        code.each_with_index { | ans, ans_idx |
          if result[ans_idx] == "?" && num.to_i == ans
            correct_num_but_incorrect_position += 1
            result[ans_idx] = "O"
            break
          end
        }
        correct_num_but_incorrect_position -= 1
      end
      result[idx] = "O"
    elsif code.include?(num.to_i)
      code.each_with_index { | ans, ans_idx |
        if result[ans_idx] == "?" && num.to_i == ans
          correct_num_but_incorrect_position += 1
          result[ans_idx] = "O"
          break
        end
      }
      
    end
  }
  return correct_guesses, correct_num_but_incorrect_position
end

def play_crack_code(board)
  puts "Crack the code!"
  # board.generate_random_code()
  guesses_num = 0
  while guesses_num < 12 do
    puts "Make your guess (6-digit number, from 1-6)"
    puts "Remaining attempts: " + (12 - guesses_num).to_s 
    guess = gets 
    guess.chomp!

    if guess.length == 4 && guess == guess.to_i.to_s
      correct, partially_correct = board.compare_guess(guess)
      if correct == 4 
      "you guessed it! good job!"
      break
      end
      
      puts correct.to_s + " colored (position & number)"
      puts partially_correct.to_s + " black (only number) \n\n"
      puts "------------------------------------------------------------\n\n"
      guesses_num += 1
    else
      puts "Not a valid input! Try again \n\n"
      puts "------------------------------------------------------------\n\n"
    end
  end
  puts "game over! The correct code was " + board.get_code().join()  
end

def get_all_possible_codes()
  all_codes = Array.new()
  for i in 1..6 do
    for j in 1..6 do
      for k in 1..6 do
        for l in 1..6 do
          code = i.to_s + j.to_s + k.to_s + l.to_s 
          all_codes.push(code)
        end
      end
    end
  end
  all_codes
end 

def convert_to_array_of_int(str) 
  str = str.split("")
  str = str.map { | num | num.to_i }
  str
end

def play_make_code(board)
  puts "What is your secrete code?"
  failed_to_guess = true
  valid_code_received = false

  while (!valid_code_received)
    hidden_code = gets 
    hidden_code.chomp!
    if hidden_code.length != 4 || hidden_code != hidden_code.to_i.to_s
      puts "invalid input. try again"
    else 
      valid_code_received = true
    end
  end
  hidden_code_string = hidden_code
  hidden_code = convert_to_array_of_int(hidden_code)
  p hidden_code
  board.set_code(hidden_code)

  puts "Alright, I'm gonna crack your code. Let the fun begin!"
  all_codes = get_all_possible_codes()
  computer_guess = 1122 

  for i in 1..12 do
    puts "Is it " + computer_guess.to_s + "?"
    if hidden_code_string == computer_guess.to_s
      puts "Haaa ha! I won!"
      failed_to_guess = false
      break
    end
    
    correct, partially_correct = board.compare_guess(computer_guess.to_s)
    puts correct.to_s + " colored (position & number)"
    puts partially_correct.to_s + " black (only number) \n\n"
    puts "------------------------------------------------------------\n\n"
  
    computer_guess = convert_to_array_of_int(computer_guess.to_s)
    all_codes.each { | guess |
      temp_correct, temp_partially_correct = compare_guess_to_given_code(computer_guess, guess)
      if temp_correct != correct || temp_partially_correct != partially_correct 
        all_codes.delete(guess)
      end
      
    }
    
    all_codes.delete(computer_guess)
    scores_for_guesses = Array.new()
    lowest_score = 9999
  
    peg_scores = Array.new(14, 0)
    all_codes.each { | guess | 
      all_codes.each { | possible_code | 
        possible_code = convert_to_array_of_int(possible_code.to_s)
        temp_correct, temp_partially_correct = compare_guess_to_given_code(possible_code, guess)
        peg_scores = keep_peg_scores(peg_scores, temp_correct, temp_partially_correct)
      }
      if peg_scores.max < lowest_score 
        lowest_score = peg_scores.max
        computer_guess = guess
      end
      # guess_and_score = [ guess, peg_scores.max ] #might cause an error?
      peg_scores.fill(0, 0, peg_scores.size)    
      # scores_for_guesses.push(guess_and_score)
    }
    puts all_codes
    if i == 11 # make a random guess if we're at our last attempt
      computer_guess = all_codes.sample
    end
  end
  if failed_to_guess
    puts "Oh no. It looks like I lost"
  end
  puts "\n"
end

def keep_peg_scores(peg_scores, c, pc) 
  if c == 0 && pc == 0
    peg_scores[0] += 1
  elsif c == 0 && pc == 1
    peg_scores[1] += 1
  elsif c == 0 && pc == 2
    peg_scores[2] += 1
  elsif c == 0 && pc == 3
    peg_scores[3] += 1
  elsif c == 0 && pc == 4
    peg_scores[4] += 1
  elsif c == 1 && pc == 0
    peg_scores[5] += 1
  elsif c == 1 && pc == 1
    peg_scores[6] += 1
  elsif c == 1 && pc == 2
    peg_scores[7] += 1
  elsif c == 1 && pc == 3
    peg_scores[8] += 1
  elsif c == 2 && pc == 0
    peg_scores[9] += 1
  elsif c == 2 && pc == 1
    peg_scores[10] += 1
  elsif c == 2 && pc == 2
    peg_scores[11] += 1
  elsif c == 3 && pc == 0
    peg_scores[12] += 1
  elsif c == 4 && pc == 0
    peg_scores[13] += 1
  else 
    puts "ERROR!"
  end
  peg_scores
end

def ask_to_choose_game_mode()
  puts "choose game mode: "
  puts "1. Crack the code"
  puts "2. Make the code"
  puts "To quit press q"
end 

# puts  board.get_code().join()

ask_to_choose_game_mode()

playing = true
while playing
  board = Board.new()
  mode = gets 
  mode.chomp!

  if mode == 'q'
    playing = false
    break
  elsif mode == '1'
    play_crack_code(board)
  elsif mode == '2'
    play_make_code(board)
  else
    "Not a valid input! Try again!"
  end
  ask_to_choose_game_mode()
end
