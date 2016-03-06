local dl = require 'dataload._env'

-- Loads Penn Tree Bank train, valid, test sets
function dl.loadPTB(batchsize, datapath, srcurl)
   -- 1. arguments and defaults
   
   -- the size of the batch is fixed for SequenceLoaders
   assert(torch.type(batchsize) == 'number')
   -- path to directory containing Penn Tree Bank dataset on disk
   datapath = datapath or paths.concat(dl.DATA_PATH, 'PennTreeBank')
   -- URL from which to download dataset if not found on disk.
   srcurl = srcurl or 'https://raw.githubusercontent.com/wojzaremba/lstm/master/data/'
   
   -- 2. load raw data, convert to tensor
   
   local file = require('pl.file')
   local stringx = require('pl.stringx')
   
   local loaders = {}
   local vocab, ivocab, wordfreq
   for i,whichset in ipairs{'train', 'valid', 'test'} do
      -- download the file if necessary
      local filename = 'ptb.'..whichset..'.txt'
      local filepath = paths.concat(datapath, filename)
      dl.downloadfile(datapath, srcurl..filename, filepath)
      local text = file.read(filepath)
      text = stringx.replace(text, '\n', '<eos>')
      local tokens = stringx.split(text)
      if whichset == 'train' then
         vocab, ivocab, wordfreq = dl.buildVocab(tokens)
      end
      local tensor = dl.text2tensor(tokens, vocab)
      
      -- 3. encapsulate into SequenceLoader
      local loader = dl.SequenceLoader(tensor, batchsize)
      loader.vocab = vocab
      loader.ivocab = ivocab
      loader.wordfreq = wordfreq
      table.insert(loaders, loader)
   end
   
   return unpack(loaders)
end
