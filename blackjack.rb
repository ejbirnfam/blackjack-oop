class Deck
  attr_accessor :cards
  def initialize
    @cards = []
    ['Diamonds', 'Hearts', 'Spades', 'Clubs'].each do |suit|
      ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'].each do |value|
        @cards << Card.new(suit, value)
      end
    end
    shuffle
  end

  def shuffle
    cards.shuffle!
  end

  def deal_a_card
    cards.pop
  end

end

class Card
  attr_accessor :suit, :value

  def initialize (s,v)
    @suit = s
    @value = v
  end
end

module Hand
  def add_card(new_card)
    cards << new_card
  end

  def show_hand
    puts "#{name}'s Hand is:"
    cards.each do |card|
      puts "#{card.value} of #{card.suit}"
    end
    puts "For a total of: #{total}"
  end

  def total
    values = cards.map{ |card| card.value }
    total = 0
    values.each do |value|
      if value == "J" || value == "Q" || value == "K"
        total += 10
      elsif value == "A"
        total += 11
      else
        total += value.to_i
      end
    end
    values.select{ |value| value == "A"}.count.times do
      if total > 21
        total -= 10
      end
    end
    total
  end

  def busted?
    total > 21
  end
end

class Dealer
  include Hand
  
  attr_accessor :name, :cards

  def initialize
    @name = "Dealer"
    @cards = []
  end
end

class Player
  include Hand
  attr_accessor :name, :cards

  def initialize(n)
    @name = n
    @cards = []
  end
end

class Game
  attr_accessor :deck, :player, :dealer
  def initialize
    @player = Player.new("Player")
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def set_player_name
    puts "What is your name?"
    player.name = gets.chomp
    system("clear")
  end

  def deal_cards
    puts "Welcome to the game #{player.name}.  Dealing cards..."
    player.add_card(deck.deal_a_card)
    player.add_card(deck.deal_a_card)
    dealer.add_card(deck.deal_a_card)
    dealer.add_card(deck.deal_a_card)
  end

  def show_hands
    puts player.show_hand
    puts dealer.show_hand
  end

  def check_for_blackjack_or_bust(player_or_dealer)
    if player_or_dealer.total == 21
      if player_or_dealer.is_a?(Dealer)
        puts "Sorry, dealer hit blackjack.  #{player.name} loses!"
      else
        puts "Blackjack!  You win!"
      end
    elsif player_or_dealer.busted?
      if player_or_dealer.is_a?(Dealer)
        puts "Dealer busted!  #{player.name} wins!"
      else
        puts "Sorry, #{player.name} busted.  #{player.name} loses."
      end
      play_again?
    end
  end

  def player_turn
    check_for_blackjack_or_bust(player) 
    while !player.busted?
      puts "Would you like to hit or stay?  Type H for hit or S to stay."
      move = gets.chomp.downcase
      if move == "h"
        player.add_card(deck.deal_a_card)
        system("clear")
        show_hands
        check_for_blackjack_or_bust(player)
      else
        break
      end
    end
  end

  def dealer_turn
    check_for_blackjack_or_bust(dealer)
    while dealer.total <= 16
      puts "The dealer needs to hit!"
      dealer.add_card(deck.deal_a_card)
      system("clear")
      show_hands
      check_for_blackjack_or_bust(dealer)
    end
  end

  def check_winner
    if player.total > @dealer.total
      puts "#{player.name} wins!"
    elsif player.total == @dealer.total
      puts "It's a tie!"
    else
      puts "#{player.name} loses!"
    end
    play_again?
  end

  def play_again?
    puts "Would you like to play again? 1) yes 2) no, exit"
    if gets.chomp == '1'
      puts "Starting new game..."
      puts ""
      deck = Deck.new
      player.cards = []
      dealer.cards = []
      start
    else
      puts "Goodbye!"
      exit
    end
  end

  def start
    set_player_name
    deal_cards
    show_hands
    player_turn
    dealer_turn
    check_winner
  end
end

game = Game.new
game.start