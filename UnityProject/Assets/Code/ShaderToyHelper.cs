/*--------------------- 
作者：妈妈说女孩子要自立自强
来源：CSDN
原文：https://blog.csdn.net/candycat1992/article/details/44039077?utm_source=copy 
版权声明：本文为博主原创文章，转载请附上博文链接！
 */
using UnityEngine;

public class ShaderToyHelper : MonoBehaviour {

    private Material _material = null;

    private bool _isDragging = false;

    // Use this for initialization
    void Start()
    {
        Renderer render = GetComponent<Renderer>();
        if (render != null)
        {
            _material = render.material;
        }

        _isDragging = false;
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 mousePosition = Vector3.zero;
        if (_isDragging)
        {
            mousePosition = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 1.0f);
        }
        else
        {
            mousePosition = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 0.0f);
        }

        if (_material != null)
        {
            _material.SetVector("iMouse", mousePosition);
        }
    }

    void OnMouseDown()
    {
        _isDragging = true;
    }

    void OnMouseUp()
    {
        _isDragging = false;
    }

}
