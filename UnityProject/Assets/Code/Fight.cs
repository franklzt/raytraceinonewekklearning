using System.Collections;
using UnityEngine;

public class Fight
{
    public Actor Player { get; private set; }
    public Actor Enemy { get; private set; }

    public MonoBehaviour MonoReference { get; set; }
    public GameObject HudGoReferencce { get; set; }


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
        ToggleUserHUD(true);
        if (FightFinish())
        {
            return;
        }
        MonoReference.StartCoroutine(MovePlayerToEnemy());
    }

    IEnumerator MovePlayerToEnemy()
    {
        ToggleUserHUD(false);
        Transform playerTrans = Player.modelReference.transform;
        Actor attackActor = Player;
        Vector3 forword = new Vector3(1, 0, 0);
        bool playAnim = false;
        bool rotatePlayer = false;
        while (true)
        {
            if (!playAnim)
            {
                PlayWalkAnim(attackActor);
                playerTrans.localPosition += forword * Time.deltaTime;
                if (playerTrans.localPosition.x >= 1.5f)
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
                    Enemy = AttackActor(attackActor, Enemy);
                    rotatePlayer = true;
                    playerTrans.localEulerAngles *= -1;
                }
                playerTrans.localPosition -= forword * Time.deltaTime;
                PlayWalkAnim(attackActor);

                if (playerTrans.localPosition.x <= -2)
                {
                    playerTrans.localEulerAngles *= -1;
                    PlayIdleAnim(attackActor);
                    EnemyAttack();
                    yield break;
                }
            }
            yield return null;
        }
    }


    public void EnemyAttack()
    {
        if (FightFinish())
        {
            return;
        }
        MonoReference.StartCoroutine(MoveEnemyToPlayer());
    }


    IEnumerator MoveEnemyToPlayer()
    {
        Transform playerTrans = Enemy.modelReference.transform;
        Actor attackActor = Enemy;
        Vector3 forword = new Vector3(1, 0, 0);
        bool playAnim = false;
        bool rotatePlayer = false;
        while (true)
        {
            if (!playAnim)
            {
                PlayWalkAnim(attackActor);
                playerTrans.localPosition -= forword * Time.deltaTime;
                if (playerTrans.localPosition.x <= -1.5f)
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
                    Player = AttackActor(attackActor, Player);
                    rotatePlayer = true;
                    playerTrans.localEulerAngles *= -1;
                }
                playerTrans.localPosition += forword * Time.deltaTime;
                PlayWalkAnim(attackActor);

                if (playerTrans.localPosition.x >= 2)
                {
                    playerTrans.localEulerAngles *= -1;
                    PlayIdleAnim(attackActor);
                    PlayerAttack();
                    yield break;
                }
            }
            yield return null;
        }
    }


    void EnemyAttackPlayer()
    {
        Player = AttackActor(Enemy, Player);
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