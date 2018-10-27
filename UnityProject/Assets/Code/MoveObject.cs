using System.Collections;
using UnityEngine;

public class MoveObject : MonoBehaviour
{
    public Transform fromObj;
    public Transform toObj;

    void Start()
    {
        StartCoroutine(MovePlayerToEnemy());
    }


    IEnumerator MovePlayerToEnemy()
    {
        Animator animator = fromObj.gameObject.GetComponent<Animator>();
        animator.Play("WALK00_F");
        while (true)
        {
            Vector3 dir = toObj.position - fromObj.position;
            dir = dir.normalized;
            if (dir.magnitude < 0.5f)
            {
                yield break;
            }
            fromObj.position += dir * Time.deltaTime;
            yield return null;
        }
    }
}
