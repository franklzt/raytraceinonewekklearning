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
        RunOutput(new Chapter1.ChapterOutPut());
        RunOutput(new Chapter2.ChapterOutPut());
        RunOutput(new Chapter3.ChapterOutPut());
    }

    void RunOutput(OutPutInterface runer)
    {
        runer.OutPutPPM();
    }



}




