# Either positive or negative lookahead, doesn't consume its input. 
#
# Example: 
#
#   str('foo').prsnt?   # matches when the input contains 'foo', but leaves it
#
class Parslet::Atoms::Lookahead < Parslet::Atoms::Base
  attr_reader :positive
  attr_reader :bound_parslet
  
  def initialize(bound_parslet, positive=true) # :nodoc:
    super()
    
    # Model positive and negative lookahead by testing this flag.
    @positive = positive
    @bound_parslet = bound_parslet
    @error_msgs = {
      :positive => "lookahead: #{bound_parslet.inspect} didn't match, but should have", 
      :negative => "negative lookahead: #{bound_parslet.inspect} matched, but shouldn't have"
    }
  end
  
  def try(source, context) # :nodoc:
    pos = source.pos

    failed = true
    catch(:error) {
      bound_parslet.apply(source, context)
      failed = false
    }
    return failed ? fail(source) : success(source)
    
  # This is probably the only parslet that rewinds its input in #try.
  # Lookaheads NEVER consume their input, even on success, that's why. 
  ensure 
    source.pos = pos
  end
  
  # TODO Both of these will produce results that could be reduced easily. 
  # Maybe do some shortcut reducing here?
  def fail(io) # :nodoc:
    if positive
      error(io, @error_msgs[:positive])
    else
      return nil
    end
  end
  def success(io) # :nodoc:
    if positive
      return nil
    else
      error(io, @error_msgs[:positive])
    end
  end

  precedence LOOKAHEAD
  def to_s_inner(prec) # :nodoc:
    char = positive ? '&' : '!'
    
    "#{char}#{bound_parslet.to_s(prec)}"
  end

  def error_tree # :nodoc:
    bound_parslet.error_tree
  end
end
