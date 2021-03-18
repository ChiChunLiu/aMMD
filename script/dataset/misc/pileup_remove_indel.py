import re
import fileinput

def remove_indel(pileup):
    '''
    modified from 
    stackoverflow: python-regex-to-match-and-remove-the-indels-in-pileup-format
    '''
    pileup = re.sub('(\^\S{1})', '', pileup)
    pileup = re.sub('\$', '', pileup)
    while True:
        match = re.search(r"[+-](\d+)", pileup)
        if match is None:
            break
        pileup = pileup[:match.start()] + pileup[match.end() + int(match.group(1)):]
    return(pileup)


for line in fileinput.input():
    line = line.strip().split()
    for i in range(4, len(line), 3):
        line[i] = remove_indel(line[i])
    line = '\t'.join(line)
    print(line)
    
