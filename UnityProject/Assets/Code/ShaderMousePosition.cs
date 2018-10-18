using UnityEngine;

public class ShaderMousePosition : MonoBehaviour
{
    public Material material;	
	void Update ()
    {
        if(material != null)
        {
            material.SetVector("iMouse", new Vector4(Input.mousePosition.x, Input.mousePosition.y, 0, 0));
        }
	}
}
