using UnityEngine;
namespace Chapter3
{
    public class ChapterOutPut : OutPutInterface
    {
           Vector3 LowerLeftCorner = new Vector3(-2.0f, -1.0f, -1.0f);
           Vector3 Horizontal = new Vector3(4.0f, 0.0f, 0.0f);
           Vector3 Vertical = new Vector3(0.0f, 2.0f, 0.0f);
           Vector3 Origin = Vector3.zero;


        public void OutPutPPM()
        {
            int nx = 200;
            int ny = 100;
            string ppm = string.Format("P3\n{0} {1} \n255\n",nx,ny);

            for (int j = ny -1; j >=0; j--)
            {
                for (int i = 0; i < nx; i++)
                {
                    Vector3 UV = new Vector3((float)i / (float)nx, (float)j / (float)ny, 0.2f);
                    float u = UV.x;
                    float v = UV.y;

                    Chapter3Ray chapter3Ray = new Chapter3Ray(Origin, LowerLeftCorner + u * Horizontal + v * Vertical);
                    Vector3 col = chapter3Ray.GetColor();
                    int ir = (int)(255.99f * col.x);
                    int ig = (int)(255.99f * col.y);
                    int ib = (int)(255.99f * col.z);

                    ppm += string.Format("{0} {1} {2}\n", ir, ig, ib);
                }
            }
            ppm.OutputFilePPM("Chapter3");
        }
    }


    public class Chapter3Ray
    {
        public Chapter3Ray() { }
        public Chapter3Ray(Vector3 origin,Vector3 direction)
        {
            A = origin;
            B = direction;
        }


        public Vector3 Origin { get { return A; } }
        public Vector3 Direction { get { return B; } }

        public Vector3 Point_At_Parameter(float t)
        {
            return A + B * t;
        }

        Vector3 A;
        Vector3 B;

        public Vector3 GetColor()
        {
            Vector3 unit_direction = B.normalized;
            float t = 0.5f * (unit_direction.y + 1.0f);
            return (1.0f - t) * Vector3.one + t *  new Vector3(0.5f, 0.7f, 1.0f);
        }
    }


}
