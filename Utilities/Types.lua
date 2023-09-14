export type CameraOptions = {
	SmoothenMovement: boolean, 
	AllowMotionBlur: boolean, 
	CameraShake: boolean, 
	CameraShakeIntensity: number, 
	AllowCameraBob: boolean, 
	DynamicFOV: boolean,
	DefaultFOV: number 
}

export type TimelineOptions = {
	Name: string, 
	VarType: number | Vector2 | Vector3 | CFrame
}

export type Track = {
	Points : {number: number}
}

export type Interactible = {
	Name : string,
	ItemIconURL : string?,
	ItemMesh : Model, 
	ItemType : string?,

	ItemUseFunction : () -> any,
	ItemUseImage: string?, 
	MaxDistance : number,
	UseKey : Enum.KeyCode
}

export type Item = {
	Name : string,
	ItemIconURL : string?,
	ItemMesh : Model, 
	ItemType : string?,

	ItemUseFunction : () -> any,
	ItemUseImage: string?, 
}

return {}
