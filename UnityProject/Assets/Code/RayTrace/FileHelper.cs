using UnityEngine;
using System.IO;
using System.Text;

public static class FileHelper
{
    public static void OutputFilePPM(this string output, string fileName)
    {
        string dir = string.Format("{0}/RayTraceInOneWeek/", Application.dataPath);
        string path = string.Format("{0}/RayTraceInOneWeek/{1}.ppm", Application.dataPath, fileName);

        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        if (File.Exists(path))
        {
            File.Delete(path);
        }
        Encoding encoding = Encoding.UTF8;
        byte[] content = encoding.GetBytes(output);
        FileStream fileStream = File.Create(path);
        fileStream.Write(content, 0, content.Length);
        fileStream.Close();
    }
}