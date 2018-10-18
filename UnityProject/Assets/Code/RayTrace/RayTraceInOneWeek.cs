using UnityEngine;

[ExecuteInEditMode]
public class RayTraceInOneWeek : MonoBehaviour
{
    public bool excute = false;
    private void Update()
    {
        if(excute)
        {
            excute = false;
            OutputFiles();
        }
    }
    void OutputFiles()
    {
        OutPutInterface chapter1 = new Chapter1.Chapter1OutPut();
        chapter1.OutPutPPM();
        chapter1 = new Chapter2.Chapter2OutPut();
        chapter1.OutPutPPM();
    }

}




