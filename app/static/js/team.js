/* Ping!. 2015.
 * All rights reserved.
 */

var ids = ["andoni","jason","toni","virginie"];
var names = {"andoni":"Andoni Garcia",
             "jason":"Jason Bern",
             "virginie":"Virginie Caspard",
             "toni":"Toni Hall"};

function mttHome(){
    var content = $(".content").empty();
    for(var name in ids){
        name = ids[name];
        var textName = names[name];
        var imgName = "/static/img/" + name + ".jpg";
        var div = $("<div></div>").attr({class:"mttPicBox box",id:name,'data-content':textName});
        var img = $("<img />").attr({class:"mttPic",src:imgName,alt:textName});
        div.append(img);
        content.append(div);
        console.log(img);
        console.log(imgName);
    }
    $("#andoni").click(function(){
        mttIndiv("andoni");
    });
    $("#jason").click(function(){
        mttIndiv("jason");
    });
    $("#virginie").click(function(){
        mttIndiv("virginie");
    });
    $("#toni").click(function(){
        mttIndiv("toni");
    });
}

function mttIndiv(id){
    var name = names[id];
    var imgName = "/static/img/" + id + ".jpg";
    var bio = {"andoni":"What's up guys. I'm the resident Commander in Chief over here at <span class='lilLogo'>Ping!</span>. I guess it comes with the territory, but I'm also the mastermind behind our tech. I'm the dude that looks responsibilities in the eye and tackles it at the first git-go. <span class='lilLogo'>Ping!</span> is my baby and I'm watching it grow at phenomenal rates.<p>When I'm not being swamped with classes, working one of my 952t0894 jobs, or pulling all nighters working on <span class='lilLogo'>Ping!</span>, I can be found kickin it table side in Chicago's nightlife scene. Everyone needs to rewind somehow. I generally like a nice movie and a bottle of wine, but sometimes the good times need to roll on.</p><p><a href='http://andonigarcia.com/'>Andoni M. Garcia</a><br /><a href='mailto:andoni@uchicago.edu'>andoni@uchicago.edu</a><br />760-845-8667</p>",
               "jason":"I know what you're thinking: can looks these good really grace the often ill-endowed world of high tech? And the answer to that is a clear, resounding 'uhuhh honeyyyy' (you know, like the one in Bound 2). Though typically given credit for possessing the body of George Clooney 20 years younger and the brilliance of Stephen Hawking, I am in fact a dude named Jason Bern, and by the decree of the Norse gods, I have been charged with cofounding a really cool startup (read: <span class='lilLogo'>Ping!</span>). When I am not cofounding really cool startups, I can be found grunting at full volume in the gym while doing <strong>NOTHING ELSE BUT AEROBICS</strong>, playing whatever form of soccer Chicago's clime will allow, seriously philosophizing (that's my major), and teaching a bunch of 5 year olds at a local Hyde Park elementary school part-time.<p>Jason Bern<br /><a href='mailto:jasonzbern@uchicago.edu'>jasonzbern@uchicago.edu</a></p>",
                "virginie":"Heyheyhey! I’m Virginie, and I work on things market-related at <span class='lilLogo'>Ping!</span> (now I’m going to add these parentheses because I’m not sure if that sentence should end in “Ping!” or “Ping!.”). Anyway. I think it’s so cool to put peoples’ behavior to good use making Ping! as user-friendly as possible.<p>As a Ping! cofounder and UChicago nerd, I spend about 97.98767% of my time working. Otherwise, you may catch a glimpse of me, at the Tour de France (among the participants, that is, or on the podium), on a piano bench, in my bed, or in da club.</p><p>Virginie Caspard<br /><a href='mailto:virginiecaspard@uchicago.edu'>virginiecaspard@uchicago.edu</a></p>",
                "toni":"Greetings! I am the Sales and Economics guru of Ping! When I am not working on Ping! related projects, I have been known to read, write, attend classes, swim and/or lift weights.</p><p>Toni Hall<br /><a href='mailto:halltk@uchicago.edu'>halltk@uchicago.edu</a></p>"};
    
    var content = $(".content").empty();
    var img = $("<img >").attr({class:"mmtIPic",src:imgName,alt:name});
    var par = $("<p></p>").attr({class:"mmtIPar"});
    var par2 = $("<p></p>").attr({class:"mmtIBack"});
    par.append(bio[id]);
    par2.append("<<<span>Back to the Team</span>");
    content.append(img, par, par2);
    $(".mmtIBack").click(function(){
        mttHome();
    });
}

$(document).ready(function(){
    console.log("Hello");
    $("#andoni").click(function(){
        mttIndiv("andoni");
    });
    $("#jason").click(function(){
        mttIndiv("jason");
    });
    $("#virginie").click(function(){
        mttIndiv("virginie");
    });
    $("#toni").click(function(){
        mttIndiv("toni");
    });
});