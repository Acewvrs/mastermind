require 'pry-byebug'

class Board
  def compare_guess(guess)
    result = Array.new(4, "?")

    correct_guesses = 0
    correct_num_but_incorrect_position = 0

    guess.split("").each_with_index { | num, idx |
      if num.to_i == @code[idx] 
        correct_guesses += 1
        if result[idx] == "O" 
          correct_num_but_incorrect_position -= 1
        end
        result[idx] = "O"
      elsif @code.include?(num.to_i)
        @code.each_with_index { | ans, ans_idx |
          if result[ans_idx] == "?" && num.to_i == ans
            correct_num_but_incorrect_position += 1
            result[ans_idx] = "O"
          end
        }
        
      end
    }
    
    return correct_guesses, correct_num_but_incorrect_position
  end

  def generate_random_code
    for i in 1..4 do 
      @code.push(rand(1..6))
    end
  end

  def get_code()
    @code
  end

  private
  def initialize
    @code = Array.new()
    # generate_random_code()
    @code = [6, 2, 5, 2]
  end
end

board = Board.new()
puts  board.get_code().join()

puts "Crack the code!"

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