from multiprocessing import Pool
import stanza
import json
from bs4 import BeautifulSoup
import os
import re
import warnings

# Ignore XMLParsedAsHTMLWarning
warnings.filterwarnings("ignore", category=UserWarning, message="It looks like you're parsing an XML document using an HTML parser.")

subs_pb = lambda a: re.sub('\<pb .+\/\>', '', a)
files = os.listdir('.')
files = [ x for x in files if '.xml' in x]
ident = '    '
nlp = stanza.Pipeline('es')
problems = []
problem_dict = {}

def load_file(filename):
    """htlm is used as a parser, instead of xml, to preserve tags 
    as much as possible, but the html parser makes all tags have lower case,
    this is fixed in fix_after_bugs.py script"""
    text = open(filename, 'r').read()
    parsed = BeautifulSoup(text, 'html.parser')
    return parsed 

def run_file(filename):
    print(filename)
    parsed = load_file(filename)
    get_us(parsed)
    with open('result/' + filename, 'w') as f:
        f.write(str(parsed))

def get_us(parsed):
    """Looks for all "u" tags"""
    us = parsed.find_all('u')
    for u in us:
        parse_u(parsed, u) 

def get_text_inside_seg(seg_text):
    """Gets all texts within segments ("seg" tags) to be annotated"""
    return '>'.join(str(seg_text).split('>')[1:]).replace('</seg>','')

def parse_u(parsed, u):
    """Assigns ids to tags following a previously created id 
    (already in the xml files)"""
    id = u.attrs['xml:id']
    segs = u.find_all('seg')
    for id_seg, seg in enumerate(segs):
        parse_seg(parsed, seg, id, id_seg + 1)

def get_annotated(seg_text):
    """Workaround to deal with any errors that might come up, especially 
    in terms of character excess, stanza has issues annotating overly long segments,
    this function adds a space before the period to circumvent the issue"""
    seg_text = subs_pb(seg_text)
    global problems
    try:
        data = nlp(seg_text)
    except RuntimeError as err:
        if 'TensorList' in str(err):
            print("error here")
            problems.append(seg_text)
            data = nlp(seg_text[0:-1] + ' .')
            print("there's an error here")
        else:
            raise Exception("Cuda memory")
    return data.to_dict()

def to_text(seg_text):
    """Organizes the annotation of "note" tags"""
    repart = seg_text.split('<note>')
    if len(repart) <= 1:
        return get_annotated(repart[0])
    for i in range(1, len(repart)):
        repart[i] = '<note>' + repart[i]
    repart = [ j  for i in repart for j in i.split('</note>') ] 
    res = [ ]
    for i in repart:
        if not i.startswith('<note>'):
            res += get_annotated(i)
        else:
            res += [{'note': i.replace('<note>', '')}]
    return res

def parse_seg(parsed, seg, id, id_seg):
    """Assigns id's to tags withing segments"""
    sentences = to_text(get_text_inside_seg(seg))
    id = str(id) + '.' + str(id_seg)
    sentence_tags = []
    for id_sentence, sentence in enumerate(sentences):
        if type(sentence) is not dict:
            a = parse_sentence(parsed, sentence, id, id_sentence + 1)
            sentence_tags.append(a)
            del a
            seg['xml:id'] = id
        else:
            b = parsed.new_tag('note')
            b.string = sentence['note']
            sentence_tags.append(b)
            del b
        seg.string = ''
        for i in sentence_tags:
            seg.append('\n' + ident)
            seg.append(i)

def fix_word_join_right(sentence):
    """Looks for join right"""
    total_len = len(sentence)
    for index, word in enumerate(sentence):
        if index == (total_len - 1):
            sentence[index]['join'] = ''
            break
        sentence[index] = fix_part_word_join_right(sentence[index], sentence[index + 1])
        if index > 0:
            if type(sentence[index - 1]['id']) is tuple:
                sentence[index]['join'] = 'right'
    return sentence

def fix_part_word_join_right(part1, part2):
    part1['join'] = ''
    try:
        start_char1, end_char1 = ( int(x.split('=')[1]) for x in part1['misc'].split('|') ) 
        start_char2, end_char2 = ( int(x.split('=')[1]) for x in part2['misc'].split('|') ) 
        if end_char1 == start_char2:
            part1['join'] = 'right'
    except:
        return part1
    return part1

def parse_sentence(parsed, sentence, id, id_sentence):
    """Organizes dependency relations annotation"""
    id = str(id) + '.' + str(id_sentence)
    tag = parsed.new_tag('s', **{'xml:id': id})
    sentence = fix_word_join_right(sentence)
    for word in sentence:
        for w in parse_word(parsed, word, id):
            tag.append('\n' + ident*2)
            tag.append(w)
    link = parsed.new_tag('linkGrp', targFunc = "head argument", type = "UD-SYN")
    for word in sentence:
        link.append('\n' + ident*2)
        link.append(parse_word_link(parsed,word,id))
    tag.append('\n' + ident*2)
    tag.append(link)
    return tag

def parse_word_link(parsed, word, id):
    """Reemoves .0 from root relation. Fixes formatting to be aligned with xml/other corpora"""
    word_id = str(id) + '.' + str(word['id'])
    data = {}
    try:
        word['head'] = '.' + str(word['head'])
        if word['head'] == '.0':
            word['head'] = ''
    except:
        pass
    try: 
        data['ana'] = 'ud-syn:' + '_'.join(word['deprel'].split(':'))
    except:
        data['ana'] = ''
    try: 
        data['target'] = '#' + str(id) + str(word['head']) + ' ' + '#' + word_id
    except:
        data['target'] = ''
    link = parsed.new_tag('link', **data)
    return link

def parse_word(parsed, word, id):
    """Partially fixes NER annotation, the other NER fixes are applied by the fix_after_bugs.py script.
    Organizes other tag annotations"""
    word_id = str(id) + '.' + str(word['id'])
    tags = []
    try:
        word['feats'] = '|' + word['feats'] 
    except:
        word['feats'] = ''
    try:
        if word['ner'] != '0' and word['ner'] != 'O':
            tags.append(parsed.new_tag('name', type = word['ner'].replace('B-','')))
    except:
        pass
    try:
        word['upos']
    except:
        w = parsed.new_tag('error')
        w.string = word['text']
        tags.append(w)
        return tags
    if word['upos'] == 'PUNCT':
        w = parsed.new_tag('pc')
    else:
        w = parsed.new_tag('w', lemma = word['lemma'])
    w['msd'] =  'UPosTag=' + word['upos'] +  word['feats'] 
    w['xml:id'] = word_id
    if word['join'] == 'right':
        w['join'] = 'right'
    w.string = word['text']
    tags.append(w)
    return tags


import pandas as pd
problems = pd.DataFrame(problem_dict)
problems.to_csv("parts_with_issues.csv", header = None)
# Workaround to identify files that couldn't be parsed


for i in range(54,400):
    print(i)
    run_file(files[i])
for i in range(54):
    print(i)
    run_file(files[i])



nlp = stanza.Pipeline('es', use_gpu = False)
run_file(files[53]) # For some reason, this file must be run in cpu instead of gpu

