module PGN
  # This class is responsible for parsing a move in Standard Algebraic
  # Notation and extracting all of the information contained in the move
  # string.
  #
  class Move
    attr_accessor :san, :player
    attr_accessor :piece, :destination, :promotion, :check, :capture, :disambiguation, :castle

    # A regular expression for matching moves in standard algebraic
    # notation
    SAN_REGEX = %r{
      (?<piece>          [BKNQR]      ){0}
      (?<destination>    [a-h][1-8]   ){0}
      (?<promotion>      =[BNQR]      ){0}
      (?<check>          [#+]         ){0}
      (?<capture>        x            ){0}
      (?<disambiguation> [a-h]?[1-8]? ){0}

      (?<castle>         O-O(-O)?     ){0}

      (?<normal>
        \g<piece>?
        \g<disambiguation>
        \g<capture>?
        \g<destination>
        \g<promotion>?
      ){0}

      \A (\g<castle> | \g<normal>) \g<check>? \z
    }x

    def initialize(move, player)
      self.player = player
      self.san    = move

      match = move.match(SAN_REGEX)

      match.names.each do |name|
        if self.respond_to?(name)
          self.send("#{name}=", match[name])
        end
      end
    end

    # Uppercase represents white, lowercase represents black
    #
    # @return [String] the piece being moved
    #
    def piece=(val)
      return if san.match("O-O")

      val ||= "P"
      @piece = self.black? ?
        val.downcase :
        val
    end

    def promotion=(val)
      if val
        val.downcase! if self.black?
        @promotion = val.delete("=")
      end
    end

    def capture=(val)
      @capture = !!val
    end

    def disambiguation=(val)
      @disambiguation = (val == "" ? nil : val)
    end

    def castle=(val)
      if val
        @castle = "K" if val == "O-O"
        @castle = "Q" if val == "O-O-O"
        @castle.downcase! if self.black?
      end
    end

    def check?
      self.check == "+"
    end

    def checkmate?
      self.check == "#"
    end

    def white?
      self.player == :white
    end

    def black?
      self.player == :black
    end

    def pawn?
      self.piece.match(/p/i)
    end

  end
end