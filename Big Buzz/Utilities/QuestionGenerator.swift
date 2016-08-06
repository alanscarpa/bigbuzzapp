//
//  QuestionGenerator.swift
//  Big Buzz
//
//  Created by Alan Scarpa on 8/6/16.
//  Copyright © 2016 ARC. All rights reserved.
//

import Foundation
import Firebase

class QuestionGenerator {
    static let sharedInstance = QuestionGenerator()
    
    func questionGenerator() {
        let allQuestions = ["Is solar power the future of electricity?",
                            "Is global warming a hoax?",
                            "Are you voting this year?",
                            "Will Donald Trump be our next president?",
                            "Do you believe in God?",
                            "Does God exist?",
                            "Will you buy a self-driving car someday?",
                            "Are you enjoying the Olympics?",
                            "Should Tesla be responsible for the deaths of people in their cars?",
                            "Will Donald Trump be the next president of the United States?",
                            "Do you care about the world's bee population?",
                            "Should Muslims be banned from entering the US?",
                            "Should fracking for oil be illegal?",
                            "Did Hillary Clinton break the law with her private email server?",
                            "Are you worried about the Zika virus?",
                            "Should the U.S. modify the 2nd Amendment?",
                            "Is Donald Trump racist?",
                            "Would you date someone who plays Pokeman Go?",
                            "Would you feel comfortable going into a public bathroom with a transgender person?",
                            "Should marijuana be legalized, nationwide?",
                            "Do you suppor the Black Lives Matter movement?",
                            "Should Planned Parenthood be defunded?",
                            "Do you support the US troops?",
                            "Are cops doing their job well in the US?",
                            "Is Barack Obama doing enough to combat ISIS?",
                            "Are you afraid of ISIS?",
                            "Should the minimum wage be raised?",
                            "Do you support same sex marriage?",
                            "Should all police officers be required to wear body cameras?",
                            "Should assault rifles be banned?",
                            "Do you think Hillary Clinton is a liar?",
                            "Would Donald Trump be a better president than Hillary Clinton?",
                            "Do you think Barack Obama was a good president?",
                            "Should cigarettes be outlawed?",
                            "Do you think vaping is safer than smoking cigarettes?",
                            "Did the democratic party obstruct Bernie Sanders in his attempt to become president?",
                            "Would you have voted for Bernie Sanders?",
                            "Do you support clean energy?",
                            "Are humans contributing to global warming?",
                            "Should abortion be illegal?",
                            "Is Islam a peaceful religion?",
                            "Do you support trickle-down economics?",
                            "Do you support labor unions?",
                            "Should the death penalty be illegal?",
                            "Should the US put boots on the ground to fight ISIS?",
                            "Do you support the Affordable Care act?",
                            "Is Snapchat better than Facebook?",
                            "Should the US increase NASA funding?",
                            "Would you purchase a self driving car?",
                            "Do you believe in the American Dream?",
                            "Is the political system \"rigged\"?",
                            "Do you post selfies?",
                            "Should the government offer student loan debt relief?",
                            "Should all combat jobs be open to women?",
                            "Should all drugs be decriminalized?",
                            "Should Syrian refugees be brought to the US?",
                            "Should women receive paid maternity leave?",
                            "Do you believe in God?",
                            "Will virtual reality be the next big thing?",
                            "Do you support gay marriage?",
                            "Should college athletes get paid?",
                            "Does technology make us more alone?",
                            "Do we give children too many trophies?",
                            "Should students be able to grade their teachers?",
                            "Should video games be considered a sport?",
                            "Does technology get in the way of learning?",
                            "Are children getting cell phones too young?",
                            "Should women be required to register for the Draft?",
                            "Should the drinking age be lowered?",
                            "Should prisoners be allowed to vote?",
                            "Is marriage an outdated institution?",
                            "Should vaccination be mandatory?",
                            "Are taxes unfair?",
                            "Is the education system a business?",
                            "Are we too late on global climate change?",
                            "Should the constitution be revised?",
                            "Are newspapers a thing of the past?",
                            "Do you support random drug testing in schools?",
                            "Should schools have uniforms?",
                            "Is hosting the Olympics a good investment?",
                            "Should downloading media without permission equivalent to theft?",
                            "Should lab grown meat be considered vegetarian? ",
                            "Is advertising misleading, hence unethical?",
                            "Has Facebook lost it's edge?",
                            "Are people too trusting of social media?",
                            "Is school teaching you the necessary skills you'll need to succeed in life?",
                            "Are zoos unethical?",
                            "Should the school day start later?",
                            "Should America convert to the metric system?",
                            "Should the cost of fast food be raised as a way to discourage unhealthy eating?",
                            "Should pharmacists be allowed to prescribe?",
                            "Is privacy an illusion? ",
                            "Is it ok to test animals for science but not commercial reasons?",
                            "Do electronic voting machines improve the voting process?",
                            "Is there life on other planets?",
                            "Do guns make society safer?",
                            "Is affirmitive action still needed?",
                            "Should unmarried couples have the legal rights of married couples?",
                            "Should a person have \"the right to die\"? ",
                            "Is “zero tolerance” a good way to assure safety?",
                            "Should we help other countries before helping ourselves?",
                            "Should human cloning be permitted?",
                            "Does the media affect our views on gender?",
                            "Should medical care be rationed?",
                            "Should there be time and spending limits on campaigning?",
                            "Should medical records/any records be “for sale”?",
                            "Should welfare recipients have to work for their money?"]
        
        
        var childUpdates = [String: AnyObject]()
        
        for (index, question) in allQuestions.enumerate() {
            let adjustedIndex = index + 1
            let adjustedDaysInSeconds = NSTimeInterval(adjustedIndex * 86400)
            let adjustedDate = NSDate().dateByAddingTimeInterval(adjustedDaysInSeconds)
            let dayMonthYear = adjustedDate.dayMonthYear()
            print(dayMonthYear)
            
            let post = ["question": question,
                        "no": 0,
                        "yes": 0
            ]
            childUpdates["/questions/\(dayMonthYear)"] = post
        }
        
        FIRDatabaseReference().updateChildValues(childUpdates) { (error, reference) in
            if let error = error {
                print("error saving question/article \(error)")
            }
        }
    }
}