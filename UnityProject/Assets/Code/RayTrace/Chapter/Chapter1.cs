namespace Chapter1
{
    public class Chapter1OutPut : OutPutInterface
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
                    float r =  (float)i / (float)nx;
                    float g =  (float)j / (float)ny;
                    float b = 0.2f;

                    int ir = (int)(255.99f * r);
                    int ig = (int)(255.99f * g);
                    int ib = (int)(255.99f * b);

                    ppm += string.Format("{0} {1} {2}\n", ir, ig, ib);
                }
            }
            ppm.OutputFilePPM("Chapter1");
        }
    }
}
