import java.io.*;
import java.util.*;

class Arrange {
    String labels[] = {
//        "L11d",
//        "L1d",
//        "L111d",
        "L1000",
        "L100",
        "L10",
        "L11100",
        "L11000",
        "L1110",
        "L1100",
        "L110",
        "L111",
        "L1111",
        "L11111",
        "L11111a",
        "L1111111",
        "L111111",
        "L1",
        "L11",
        "L1_S",
        "L11100_S",
        "L11_S",
        "L111_S",
        "L1111_S",
        "L11111_S",
        "L111111_S",
        "L1111111_S",
        "L1_U",
        "L11_U",
        "L111_U",
        "L1111_U",
        "L11111_U",
        "L111111_U",
        "L1111111_U",
        "L1_T",
        "L11_T",
        "L111_T",
//        "L1110_S",
        "L1111100_S",
        "L111110_S",
    };

    static HashMap<String,Block> entryPoints = new HashMap<String,Block>();
    static Vector<Block> blockVector = new Vector<Block>();
    static int blockCount = 0;
    static int cutOff = 50;
    static Block error =null;

    void run() {
        entryPoints.put("ERROR", new Block("ERROR", -1));
        entryPoints.put("FASTER", new Block("FASTER", -2));
        entryPoints.put("SLOWER", error = new Block("SLOWER", -3));
        for (String s: labels) {
            Block b = new Block(s, blockCount);
            blockVector.add(b);
            blockCount++;
            b = new Block(b, blockCount);
            blockVector.add(b);
            blockCount++;
        }
        for(Block b: blockVector) {
            b.patchReferences();
        }
        for(Block b: blockVector) {
            if (!b.used) {
                System.err.println("No reference to " + b.bbName);
            }
        }
        for(int i = 0; i < 15; i++) { // 15
            optimise(20); // 20
            System.err.println("Cost " + cost() + " (cutoff " + cutOff + ")");
            if (cost() < 100000) {
                cutOff--;
            }
        }
        copy("headerS");
        for(Block b: blockVector) {
            System.out.println(b.theCode());
        }
        copy("trailerS");
    }

    int cost() {
        int costs = 0;
        for(int loc = 0; loc < blockCount; loc++) {
            Block b = blockVector.get(loc);
            costs += b.cost();
        }        
        return costs;
    }

    void swapBlocks(int j, int k) {
        Block a = blockVector.get(j);
        Block b = blockVector.get(k);
        blockVector.set(j, b);
        blockVector.set(k, a);
        a.location = k;
        b.location = j;
    }

    void optimise(int n) {

        int minCost = cost();
        int minJ = -1;
        int minK = -1;
        for(int i = 0; i < n; i++) {
            System.err.println("  -- Cost " + minCost);
            for(int j = 0; j < blockCount; j++) {
                for(int k = j+1; k < blockCount; k++) {
                    swapBlocks(j, k);
                    if (cost() < minCost) {
                        minJ = j;
                        minK = k;
                        minCost = cost();
                    }
                    swapBlocks(j, k);                    
                }
            }
            if (minJ != -1) {
                swapBlocks(minJ, minK);
            } else {
                break;
            }
            if (minCost < 100000) {
                break;
            }
        }
    }

    void copy(String s) {
        try {
            BufferedReader bi = new BufferedReader(new FileReader("states/" + s));
            while(true) {
                String line = bi.readLine();
                if (line == null) {
                    return;
                }
                System.out.println(line);
            }
        } catch (Exception e) {
            System.err.println("Exception " + e + " on " + s);
        }
    }

    public static void main(String args[]) {
        new Arrange().run();
    }
}

class Block {
    Vector<Block> refs = new Vector<Block>();
    Vector<String> refsI = new Vector<String>();
    String bbName;
    int location;
    boolean used = false;
    String code = "";

    Block(String s, int location) {
        boolean beforeBru= true;
        bbName = s;
        this.location = location;        
        if (!s.startsWith("L")) {
            return;
        }
        try {
            BufferedReader bi = new BufferedReader(new FileReader("states/" + s));
            while(true) {
                String line = bi.readLine();
                if (line == null) {
                    return;
                }
                if (beforeBru) {
                    code = code + line + "\n";
                }
                if (line.contains("BRU")) {
                    beforeBru= false;
                }
                if (line.contains(":")) {
                    addEntrypoint(line,this);
                }
                if (!beforeBru) {
                    if (line.contains("SLOWER")) {
                        addReference("SLOWER");
                    } else if (line.contains("FASTER")) {
                        addReference("FASTER");
                    } else if (line.contains("ERROR")) {
                        addReference("ERROR");
                    } else if ((line.contains(" BL") || line.contains(" BR")) && line.contains(" L")) {
                        addReference(line);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Exception " + e + " in " + s);
        }
    }

    Block(Block b, int location) {
        bbName = inverse(b.bbName);
        String lines[] = b.code.split("\n");
        for(String l: lines) {
            if (l.contains(":")) {
                String i = inverse(l);
                code += i + "\n";
                addEntrypoint(i,this);
            } else if (l.contains(" bf ") || l.contains(" bt ") || l.contains(" bu ") ) {
                code += inverse(l) + "\n";
            } else if (l.contains(" BR")) {
                code += inverse(l) + "\n";
            } else {
                code += l + "\n";
            }
        }
        this.location = location;        
        for(String s: b.refsI) {
            refsI.add(0, inverse(s));
        }
    }
    
    String inverse(String s) {
        boolean inversing = true;
        String r = "";
        for(int i = 0; i < s.length(); i++) {
            if (inversing && s.charAt(i) == '0') {
                r += '1';
            } else if (inversing && s.charAt(i) == '1') {
                r += '0';
            } else if (s.charAt(i) == '_') {
                r += '_';
                inversing = false;
            } else {
                r += s.charAt(i);
            }
        }
        return r;
    }

    void addEntrypoint(String line, Block b) {
        String label = line.replaceAll(".* L","L").replaceAll(":.*","");
        Arrange.entryPoints.put(label, b);
    }

    void addReference(String line) {
        String label1 = line.replaceFirst(".* L","L").replaceAll("[ /].*","");
        String label = label1.replaceAll("[ /].*","").replaceAll("z","");
//        System.out.println("Line " + line + " label " + label1 + " -- " + label);
        refsI.add(label);
    }

    void patchReferences() {
        for(String s: refsI) {
            Block b = Arrange.entryPoints.get(s);
            if (b == null) {
                System.err.println("Label " + s + " not found in " + bbName);
                refs.add(Arrange.error);
            } else {
                //             System.err.println("Label " + s + " found in " + bbName);
                b.used = true;
                refs.add(b);
            }
        }
    }

    int cost() {
        int costs = 0;
        for(Block b: refs) {
            if (b.location < 0) {
                continue;
            }
            int c = location - b.location;
             if (c < 0) {
                c = -c;
            }
            if (c > Arrange.cutOff) {
                c += 100000;
            }
            costs += c;
        }
        return costs;
    }
    
    String theCode() {
        int k =0;
        for(Block b : refs) {
            if (b.location < 0) {
                if (location < Arrange.blockCount / 2) {
                    code += "  BLRB_u10 B" + b.bbName + "\n";
                } else {
                    code += "  BLRF_u10 F" + b.bbName + "\n";
                }
            } else if (b.location <= location) {
                code += "  BLRB_u10 " + refsI.get(k) + "\n";
            } else {
                code += "  BLRF_u10 " + refsI.get(k) + "\n";
            }
            k++;
        }
        return code;
    }
}
