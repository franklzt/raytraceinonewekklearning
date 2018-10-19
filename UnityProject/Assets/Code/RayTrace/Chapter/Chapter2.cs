using UnityEngine;
namespace Chapter2
{
    public class ChapterOutPut : OutPutInterface
    {
        public void OutPutPPM()
        {
            int nx = 200;
            int ny = 100;
            string ppm = string.Format("P3\n{0} {1} \n255\n",nx,ny);

            for (int j = ny -1; j >=0; j--)
            {
                for (int i = 0; i < nx; i++)
                {
                    Vector3 col = new Vector3((float)i / (float)nx, (float)j / (float)ny, 0.2f);
                 
                    int ir = (int)(255.99f * col.x);
                    int ig = (int)(255.99f * col.y);
                    int ib = (int)(255.99f * col.z);

                    ppm += string.Format("{0} {1} {2}\n", ir, ig, ib);
                }
            }
            ppm.OutputFilePPM("Chapter2");
        }
    }
}
