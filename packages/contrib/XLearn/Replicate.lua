
local Replicate, parent = torch.class('nn.Replicate','nn.Module')

function Replicate:__init(nf)
   parent.__init(self)
   self.nfeatures = nf
end

function Replicate:forward(input)
   --self.output:resize(input:size(1),input:size(2),self.nfeatures)
   local sz = torch.LongStorage(input:dim()):copy(input:size()):resize(input:dim()+1,true)
   sz[sz:size()] = self.nfeatures
   local st = torch.LongStorage(input:dim()):copy(input:stride()):resize(input:dim()+1,true)
   st[st:size()] = 0
   self.output = torch.Tensor(input:storage(),input:storageOffset(),sz,st)
   -- for k=1,self.output:size(3) do
   --    self.output:select(3,k):copy(input)
   -- end
   return self.output
end

function Replicate:backward(input, gradOutput)
   self.gradInput:resizeAs(input):zero()
   for k=1,gradOutput:size(3) do
      self.gradInput:add(gradOutput:select(3,k))
   end
   return self.gradInput
end
   

function Replicate:write(file)
   parent.write(self,file)
   file:writeInt(self.nfeatures)
end

function Replicate:read(file)
   parent.read(self,file)
   self.nfeatures = file:readInt()
end
