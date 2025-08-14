//
//  MyDrinkingHabitRefDoc.swift
//  CalmscientIOS
//
//  Created by NFC User on 26/03/25.
//

import Foundation
import UIKit

struct DrinkingData {
    static let shared: [String: (UIImage, [String])] = [
        "Moderate drinking": (UIImage(named: "check") ?? UIImage(), [
            "Always drink with the moderate drinking standard.",
            "Can effortlessly commit alcohol free plan for week or month.",
            "Can choose to drink or not even though people around you are drinking."
        ]),
        
        "Consumo moderado": (UIImage(named: "check") ?? UIImage(), ["Siempre bebes siguiendo el estándar de consumo moderado.", "Puedes comprometerte sin esfuerzo a un plan sin alcohol durante una semana o un mes.", "Puedes elegir beber o no, aunque las personas a tu alrededor estén bebiendo."]),
        
        "Moderate everyday drinking": (UIImage(named: "check") ?? UIImage(), [
            "Always drink with the moderate drinking standard but struggles to have alcohol-free day.",
            "Drink daily as sleep aids or relaxation.",
            "Expect to have a drink after work or in the evening and get irritated or stressed when you can't have it."
        ]),
        
        "Consumo moderado diario": (UIImage(named: "check") ?? UIImage(), ["Siempre bebes siguiendo el estándar de consumo moderado, pero me cuesta tener un día sin alcohol.", "Bebes a diario como ayuda para dormir o para relajarte.", "Anhelas tomar un trago después del trabajo o por la noche, y te irritas cuando no puedes hacerlo."]),

        "Social / weekend binge drinking": (UIImage(named: "check") ?? UIImage(), [
            "Casual drinking turns into doing things that you normally wouldn't do or that go against your judgment while you're sober, such as driving under alcohol influence.",
            "Often seek the mood-altering effects (the buzz) or using alcohol as a coping mechanism, sometimes in isolation.",
            "Get defensive when someone tries to limit your consumption or asks you to stop.",
            "Remember? Binge drinking is:\nMen - Up to 5 or more drinks within 2 hrs\nWomen - Up to 4 or more drinks within 2 hrs."
        ]),
        
        "Consumo excesivo social / de fines de semana": (UIImage(named: "check") ?? UIImage(), ["El consumo ocasional de alcohol te mueve a hacer cosas que normalmente no harías o que van en contra de tu juicio cuando estás sobrio, como conducir bajo los efectos del alcohol.", "A menudo buscas los efectos que alteran el estado de ánimo (el subidón) o usas el alcohol como un mecanismo de afrontamiento, a veces en aislamiento.", "Te pones a la defensiva cuando alguien intenta limitar tu consumo o te pide que dejes de beber.", "¿Recuerdas? El consumo excesivo ocasional (binge drinking) es: Hombres: hasta 5 o más bebidas dentro de las 2 horas Mujeres: hasta 4 o más bebidas dentro de las 2 horas."]),

        "Problematic drinking": (UIImage(named: "check") ?? UIImage(), [
            "Drinking until drunk.",
            "Going to work drunk or drinking on the job.",
            "Driving while drunk or have driven while drunk.",
            "Getting in trouble with the law or being injured due to drinking.",
            "Doing something under the influence of alcohol that they would not otherwise do.",
            "Having problems at school, with social relationships, or with family members because of drinking.",
            "Using alcohol to decrease anxiety or sadness.",
            "Lying about or trying to hide drinking habits.",
            "Needing more alcohol to feel its effects.",
            "Feeling grouchy, resentful, or unreasonable when not drinking."
        ]),
        
        "Consumo problemático": (UIImage(named: "check") ?? UIImage(), ["Beber hasta emborracharse", "Ir a trabajar borracho o beber durante el trabajo", "Conducir bajo los efectos del alcohol o haber conducido borracho.", "Meterse en problemas con la ley o sufrir lesiones debido al consumo de alcohol.", "Hacer algo bajo la influencia del alcohol que no harían de otra manera.", "Tener problemas en la escuela, con las relaciones sociales o con los miembros de la familia a causa del consumo de alcohol.", "Usar el alcohol para disminuir la ansiedad o la tristeza.", "Mentir o intentar ocultar los hábitos de consumo de alcohol.", "Necesitar más alcohol para sentir sus efectos.", "Sentirse irritable, resentido o irrazonable cuando no se bebe."]),
        
        "Thinking about quitting": (UIImage(named: "check") ?? UIImage(), [
            "You are considering it but haven't made a decision yet.",
            "That's perfectly ok! We will guide you through the benefits of quitting smoking, and then you can decide if you'd like to create a plan for quitting.",
            "Move to Make a plan."
        ]),
        
        "Está pensando en dejar de fumar": (UIImage(named: "check") ?? UIImage(), ["Lo está considerando pero aún no ha tomado una decisión.", "¡Está perfectamente bien! Lo guiaremos a través de los beneficios de dejar de fumar y luego podrá decidir si desea crear un plan para dejar de fumar.", "Pase a hacer un plan."]),
        
        "Getting ready to quit": (UIImage(named: "check") ?? UIImage(), [
            "You've decided to quit smoking.",
            "Great decision! We will guide you on how to create a solid plan and help you stay focused on your journey.",
            "Move to Make a plan."
        ]),
        
        "Preparándose para dejar de fumar": (UIImage(named: "check") ?? UIImage(), ["Has decidido dejar de fumar.", "¡Excelente decisión! Te guiaremos sobre cómo crear un plan sólido y te ayudaremos a mantenerte concentrado en tu viaje.", "Pasa a hacer un plan."]),
        
        "Quitting": (UIImage(named: "check") ?? UIImage(), [
            "You've already started or set a date to quit smoking.",
            "That's great! We will help you create a strategic plan and stay focused on your goal.",
            "Move to Make a plan."
        ]),
        
        "Dejar de fumar": (UIImage(named: "check") ?? UIImage(), ["Ya comenzó o fijó una fecha para dejar de fumar.", "¡Eso es genial! Lo ayudaremos a crear un plan estratégico y mantenerse enfocado en su objetivo.", "Pase a hacer un plan."]),
        
        "Staying smoke-free": (UIImage(named: "check") ?? UIImage(), [
            "You're focusing on avoiding relapse and keeping up your progress.",
            "That's fantastic. It's important not to let your guard down. We will be here to support you to stay strong.",
            "Move to Make a plan to register the day you started quitting smoking, then you can use Stay focused."
        ]),
        
        "Permanecer libre de humo": (UIImage(named: "check") ?? UIImage(), ["Te estás concentrando en evitar recaídas y mantener tu progreso.", "Eso es fantástico. Es importante no bajar la guardia. Estaremos aquí para ayudarte a mantenerte fuerte.", "Pasa a Haz un plan para registrar el día en que empezaste a dejar de fumar, luego podrás usar Mantente enfocado."])
    ]
}
