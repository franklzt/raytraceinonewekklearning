using UnityEngine;
using UnityEngine.UI;

public class LoadShader : MonoBehaviour
{
    string shaderPath = "ShaderToy";
    public Transform imageRoot;
    void Start () {
        Shader[] shaders = Resources.LoadAll<Shader>(shaderPath);
        for (int i = 0; i < shaders.Length; i++)
        {
            Material material = new Material(shaders[i]);
            GameObject Go = new GameObject();
            Go.transform.SetParent(imageRoot);
            Image image = Go.AddComponent<Image>();
            image.material = material;
        }
	}
	
	
}
