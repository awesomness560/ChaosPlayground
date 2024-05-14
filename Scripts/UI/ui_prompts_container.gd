extends VBoxContainer
class_name ControlPrompts

@export var iconLabelPair : PackedScene ##Scene containing the HBox with inputs

func config(inputDict : Dictionary): ##Pass in the dictionary with inputs and descriptions
	for key in inputDict.keys():
		var labelPairInstance : HBoxContainer = iconLabelPair.instantiate()
		
		#HACK: I am using get_child here, so if someone messes with the order of the children. It would break
		var iconResource : ControllerIconTexture = labelPairInstance.get_child(0).texture
		iconResource.path = key
		
		var label : RichTextLabel = labelPairInstance.get_child(2)
		label.add_text(inputDict[key])
		
		add_child(labelPairInstance)
