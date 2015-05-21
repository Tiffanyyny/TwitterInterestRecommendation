
require 'random/online'

class TagGenerator
   attr_accessor :map1,:map2,:map3,:map4
   
   def initialize
     @map1 = read_map('combo1.txt')
     @map2 = read_map('combo2.txt')
     @map3 = read_map('combo3.txt')
     @map4 = read_map('combo4.txt')
   end
   
   def read_map(filename)
     f = File.new(filename,'r')
     map = []
     f.each_line {|line|
        map.push line
     }
     return map
   end
   
def generate_tags(filename)
  n = [20,190,1140,4845]
  
  #generate tags for 2000 twitter users
  file = File.new(filename,"w")
  rorg = RealRand::RandomOrg.new
  a = rorg.randnum(2000, 1, 4)
  b = Hash.new(0)
  a.each do |v|
    b[v] += 1
  end
  
  #for each tag num, randomly generate tag set
  b.each do |k, v|
    a = rorg.randnum(v,1,n[k-1])
    a = a.uniq
    a.each do |num|
      tag = tagsMap(num,k)
      file.write(tag)
    end
  end  
  file.close unless file == nil
end


def tagsMap(v,k)
  if(k == 1)
    return map1[v-1]
  elsif(k == 2)
    return map2[v-1]
  elsif(k == 3)
    return map3[v-1]
  else
    return map4[v-1]
  end
end
end

tagGenerator = TagGenerator.new
tagGenerator.generate_tags("tags.txt")

