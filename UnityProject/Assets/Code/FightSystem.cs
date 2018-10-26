using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class FightSystem : MonoBehaviour
{
    public GameObject playerModel;
    public GameObject enemyModel;

    public Text PlayerHp;
    public Text EnemyHp;
    public Button AttackButton;

    public GameObject HudGoReferencce;


    Fight fight;


    private void Start()
    {

        AttackButton.onClick.AddListener(OnPlayerAttack);
        fight = new Fight(playerModel, enemyModel);
        fight.MonoReference = this;
        fight.HudGoReferencce = HudGoReferencce;
    }


    void OnPlayerAttack()
    {
        fight.PlayerAttack();
    }



    public void UpdateActorHU(Actor actor, Text text)
    {
        text.text = string.Format("{0} :{1}", actor.ActorName, actor.HP);
    }

    private void Update()
    {
        UpdateActorHU(fight.Player, PlayerHp);
        UpdateActorHU(fight.Enemy, EnemyHp);
    }
}


