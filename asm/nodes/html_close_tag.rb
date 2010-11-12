module ERBGrammar
  class HTMLCloseTag < Treetop::Runtime::SyntaxNode
    attr_accessor :index

    def eql?(other)
      return false unless other.is_a?(self.class)
      name == other.name
    end

    def hash
      name.hash
    end

    def name
      tag_name.text_value
    end

    def inspect
      sprintf("%s %d: %s", self.class, @index, name)
    end

    def pair_match?(other)
      other.is_a?(HTMLOpenTag) && name == other.name
    end

    def to_s(indent_level=0)
      sprintf("%s%d: /%s", Tab * indent_level, @index, name)
    end
  end
end