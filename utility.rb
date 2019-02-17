def index_of_max_of(arr)
  arr.each_with_index.max[1]
end

class Hey
  attr_accessor :array
  def initialize(arr = nil)
    if arr.nil?
      @array = Array.new(2){rand(0..1)}
    else
      @array = correct(arr)
    end
  end

  def correct(arr)
    arr[arr.size - 1] = 10
    return arr
  end
end
