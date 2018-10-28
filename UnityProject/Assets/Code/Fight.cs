using System.Collections;
using UnityEngine;
using UnityEngine.Events;

public class Fight
{
    public Actor Player { get; private set; }
    public Actor Enemy { get; private set; }

    public MonoBehaviour MonoReference { get; set; }
    public GameObject HudGoReferencce { get; set; }

    public bool AutoFight { get; set; }


    void ToggleUserHUD(bool state)
    {
        if (HudGoReferencce == null) return;
        HudGoReferencce.SetActive(state);
    }


    public bool FightFinish()
    {
        return Player.HP <= 0 || Enemy.HP <= 0;
    }

    public void PlayerAttack()
    {
        if (FightFinish())
        {
            return;
        }
        MonoReference.StartCoroutine(MovePlayerToEnemy(Player, Enemy, () =>
        {
            Enemy = AttackActor(Player, Enemy);
        }, EnemyAttack));
        ToggleUserHUD(false);
    }

    public void EnemyAttack()
    {
        if (FightFinish())
        {
            return;
        }
        MonoReference.StartCoroutine(MovePlayerToEnemy(Enemy, Player, () =>
        {
            Player = AttackActor(Enemy, Player);
        }, () =>
        {
            ToggleUserHUD(true);
            if (AutoFight)
            {
                PlayerAttack();
            }
        }));
    }

    void MoveToTarget(Transform moveObject, Vector3 from, Vector3 to, float speed = 1.0f)
    {
        Vector3 dir = to - from;
        Vector3 moveDirection = dir.normalized;
        moveObject.position += moveDirection * Time.deltaTime * speed;
    }


    bool FinishMove(Transform trans, Vector3 target, float conditionDistance)
    {
        Vector3 disVector = trans.position - target;
        float distance = disVector.magnitude;
        return distance <= conditionDistance;
    }


    IEnumerator MovePlayerToEnemy(Actor moveActor, Actor targetActor, UnityAction OnHitAction, UnityAction OnNextAction)
    {
        Actor attackActor = moveActor;
        bool playAnim = false;
        bool rotatePlayer = false;

        Transform playerTrans = moveActor.modelReference.transform;
        Transform enemyTrans = targetActor.modelReference.transform;

        Vector3 originalPosition = playerTrans.position;
        Vector3 targetPosition = enemyTrans.position;

        while (true)
        {
            if (!playAnim)
            {
                PlayWalkAnim(attackActor);
                MoveToTarget(playerTrans, originalPosition, targetPosition);
                bool finishMove = FinishMove(playerTrans, targetPosition, 0.5f);
                if (finishMove)
                {
                    playAnim = true;
                    PlayAttackAnim(attackActor);
                }
            }

            if (playAnim)
            {

                if (!rotatePlayer)
                {
                    yield return new WaitForSeconds(GetActorAnimLength(attackActor.ActorAnimName.AttackAnim));
                    if (OnHitAction != null)
                    {
                        OnHitAction();
                    }
                    rotatePlayer = true;
                    playerTrans.localEulerAngles *= -1;
                }
                MoveToTarget(playerTrans, playerTrans.position, originalPosition);
                PlayWalkAnim(attackActor);

                bool finishMove = FinishMove(playerTrans, originalPosition, 0.01f);
                if (finishMove)
                {
                    playerTrans.localEulerAngles *= -1;
                    PlayIdleAnim(attackActor);

                    if (OnNextAction != null)
                    {
                        OnNextAction();
                    }
                    //EnemyAttack();
                    yield break;
                }
            }
            yield return null;
        }
    }






    string[] allAnimName = { "SLIDE00", "WAIT00", "WALK00_F", "DAMAGED00" };
    float[] allAnimLength = { 1.36f, 1.0f, 1.3f, 1.133f };
    float GetActorAnimLength(string animName)
    {
        for (int i = 0; i < allAnimName.Length; i++)
        {
            if (animName == allAnimName[i])
            {
                return allAnimLength[i];
            }
        }
        return 1.0f;
    }


    public Fight(GameObject playerGo, GameObject enemyGo)
    {
        Player = CreateActor(100, 10, playerGo, "Player");
        Enemy = CreateActor(100, 5, enemyGo, "Enemy");
    }

    public Actor AttackActor(Actor attakActor, Actor damageActor)
    {
        damageActor.HP -= attakActor.Attack;
        return damageActor;
    }


    Actor CreateActor(float hp, float attack, GameObject modelReference, string name)
    {
        Actor actor = new Actor() { HP = hp, Attack = attack, modelReference = modelReference, ActorName = name };
        actor = AddAnim(actor);
        actor = AddAnimName(actor);
        return actor;
    }

    Actor AddAnim(Actor actor)
    {
        actor.Animator = actor.modelReference.GetComponent<Animator>();
        return actor;
    }

    Actor AddAnimName(Actor actor)
    {
        ActorAnimName animName = new ActorAnimName();
        animName.AttackAnim = "SLIDE00";
        animName.IdleAnim = "WAIT00";
        animName.WalkAnim = "WALK00_F";
        animName.DamageAnim = "DAMAGED00";
        actor.ActorAnimName = animName;
        return actor;
    }



    void PlayAttackAnim(Actor actor)
    {
        actor.Animator.Play(actor.ActorAnimName.AttackAnim);
    }

    void PlayIdleAnim(Actor actor)
    {
        actor.Animator.Play(actor.ActorAnimName.IdleAnim);
    }

    void PlayWalkAnim(Actor actor)
    {
        actor.Animator.Play(actor.ActorAnimName.WalkAnim);
    }

    void PlayDamageAnim(Actor actor)
    {
        actor.Animator.Play(actor.ActorAnimName.DamageAnim);
    }
}

public struct ActorAnimName
{
    public string AttackAnim { get; set; }
    public string IdleAnim { get; set; }
    public string WalkAnim { get; set; }
    public string DamageAnim { get; set; }
}

public struct Actor
{
    public ActorAnimName ActorAnimName { get; set; }
    public float HP { get; set; }
    public float Attack { get; set; }
    public GameObject modelReference { get; set; }
    public string ActorName { get; set; }
    public Animator Animator { get; set; }
}