--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

PJ.quests = {
    ["Broń palna"]={
        {desc="Czy musisz posiadać licencję na broń by korzystać z pistoletu 9mm?",
        options={
            {name="Tak.", next="+"},
            {name="Nie.", next="-"},
            {name="Nie, jeżeli posiada tłumik.", next="-"},
        }},
        
        {desc="Czy podczas kontroli przez SAPD musisz okazać licencję na broń?",
        options={
            {name="Nie.", next="-"},
            {name="Tak.", next="+"},
        }},
        
        {desc="Co to za rodzaj broni?",
        image="bron2.png",
        options={
            {name="Pistolet maszynowy.", next="-"},
            {name="Karabin.", next="-"},
            {name="Karabin szturmowy.", next="+"},
        }},
        
        {desc="Co to za model broni?",
        image="bron3.png",
        options={
            {name="Tec9.", next="-"},
            {name="M4.", next="+"},
            {name="Desert Eagle.", next="-"},
        }},
        
        {desc="Czy użycie broni w obronie własnej jest przestępstwem?",
        options={
            {name="Tak.", next="-"},
            {name="Nie.", next="+"},
        }},
        
        {desc="Zaznacz punkt, w którym wymieniono tylko pistolety maszynowe.",
        options={
            {name="AK-47, M4, SMG.", next="-"},
            {name="Pistolet 9mm, Mikro PM, SMG.", next="-"},
            {name="Tec9, Mikro PM, SMG.", next="+"},
        }},
        
        {desc="Gdzie znajduje się serwerowa strefa bezprawia?",
        options={
            {name="Los Santos.", next="+"},
            {name="San Fierro.", next="-"},
            {name="Las Venturas.", next="-"},
        }},
        
        {desc="Co to za model broni?",
        image="bron1.png",
        options={
            {name="Obrzyn.", next="+"},
            {name="Strzelba.", next="-"},
            {name="Strzelba bojowa.", next="-"},
        }},
        
        
        {desc="Ile posiada AK-47 naboji w swoim magazynku?",
        options={
            {name="60.", next="-"},
            {name="45.", next="-"},
            {name="30.", next="+"},
        }},
        
        {desc="Gdzie legalnie możemy zakupić broń na serwerze?",
        options={
            {name="San Fierro, Ocean Flats.", next="-"},
            {name="Las Venturas, Blackfield College.", next="-"},
            {name="Blueberry.", next="+"},
        }},
    },

    ["A"]={
        {desc="Przed wyjazdem na motocyklu:",
        image="a1.png",
        options={
            {name="Upewniam się, że zabrałem wszystkie środki bezpieczeństwa.", next="+"},
            {name="Sprawdzam stan wizualny mojego pojazdu.", next="-"},
        }},
        {desc="Przed wyjazdem z drugą osobą:",
        image="a2.png",
        options={
            {name="Zabieram drugi kask i oddaje go w jej ręce.", next="+"},
            {name="Wyjeżdżam, bo nie zamierzam z nią przejechać długiej trasy.", next="-"},
        }},
        {desc="Na skrzyżowaniach:",
        image="a3.png",
        options={
            {name="Zachowuje szczególną ostrożność, zwracam uwagę na innych.", next="+"},
            {name="Skoro jadę motocyklem mam zawsze pierwszeństwo.", next="-"},
        }},
        {desc="Na odcinkach gdzie występuje sygnalizacja świetlna:",
        image="a4.png",
        options={
            {name="Zatrzymuję się na każdym czerwonym, rozglądam się przed przejazdem.", next="+"},
            {name="Ścigam się z każdym, którego napotkam, nie zważam na kolor świateł.", next="-"},
        }},
        {desc="Przy bardzo zatłoczonych ulicach:",
        image="a5.png",
        options={
            {name="Ustawiam się za pojazdem przede mną, czekam, aż pojedzie dalej.", next="+"},
            {name="Przejeżdzam poboczami, aby przypadkiem się nie spóźnić.", next="-"},
        }},
        {desc="Widząc miejsce pełne pieszych:",
        image="a6.png",
        options={
            {name="Zwalniam i ustępuję pierwszeństwa jeśli jest taka potrzeba.", next="+"},
            {name="Dodaję gazu i używam sygnału dźwiękowego, aby się przesunęli.", next="-"},
        }},
        {desc="Na autostradzie:",
        image="a7.png",
        options={
            {name="Zmieniam pas co parę chwil, nie patrzę w lusterka.", next="-"},
            {name="Jeśli jest taka potrzeba zmieniam pas, zawsze patrzę za siebie.", next="+"},
        }},
        {desc="Na pustej jezdni:",
        image="a8.png",
        options={
            {name="Obserwuję czy ktoś nie zamierza włączyć się do ruchu.", next="+"},
            {name="Jadę na tylnim kole i staram się popisać przed innymi.", next="-"},
        }},
        {desc="Przekraczam prędkość tylko wtedy gdy:",
        image="a9.png",
        options={
            {name="W pobliżu nie ma żadnych radiowozów.", next="-"},
            {name="Nigdy jej nie przekraczam.", next="+"},
        }},
        {desc="Podczas manewru wymijania:",
        image="a10.png",
        options={
            {name="Używam kierunkowskazu, aby powiadomić o tym innych.", next="+"},
            {name="Po prostu wymijam drugą osobę, przecież nic mi nie zagraża.", next="-"},
        }},
    },

    ["B"]={
        {desc="W jakiej kolejności pojazdy będą kontynuować jazdę?",
        image="1.png",
        options={
            {name="Pojazd A ustąpi pierwszeństwa pojazdowi B.", next="-"},
            {name="Pojazd A przejedzie pierwszy, pojazd B po nim.", next="+"},
        }},
        {desc="W jakiej kolejności pojazdy będą kontynuować ruch?",
        image="2.png",
        options={
            {name="Pojazd A przejedzie pierwszy, pojazd B po nim.", next="+"},
            {name="Pojazd A ustąpi pierwszeństwa pojazdowi B.", next="-"},
        }},
        {desc="Na co musisz zwracać uwagę w obrębie salonów pojazdów?",
        image="3.png",
        options={
            {name="Trzeba dostosować prędkość do warunków.", next="+"},
            {name="Nie zwracam uwagi na innych.", next="-"},
        }},
        {desc="W obrębie stacji benzynowych zwracam uwagę na:",
        image="4.png",
        options={
            {name="Cena benzyny, koszt hot-doga.", next="-"},
            {name="Inne osoby, źródła ognia, przypuszczalne niebezpieczeństwa.", next="+"},
        }},
        {desc="Słysząc alarm w pobliskiej jednostce straży należy:",
        image="5.png",
        options={
            {name="Zapewne to tylko ćwiczenia, nie zwracam na to uwagi.", next="-"},
            {name="Zachować uwagę, uważać na pojazdy straży.", next="+"},
        }},
        {desc="Na autostradzie:",
        image="6.png",
        options={
            {name="Zachowuje odstępy, obserwuje innych uczestników ruchu.", next="+"},
            {name="Korzystam z pasa alarmowego, nie zwracam uwagi na bezpieczeństwo innych.", next="-"},
        }},
        {desc="Korzystając z parkingu:",
        image="7.png",
        options={
            {name="Nie zwracam uwagi na innych, interesuje mnie tylko znalezienie miejsca.", next="-"},
            {name="Dostosowuje prędkość do warunków, uważam na pieszych i inne pojazdy. ", next="+"},
        }},
        {desc="Zasady przy przejazdach kolejowych to:",
        image="8.png",
        options={
            {name="W razie konieczności zatrzymuję się, ruszam tylko kiedy wskaże sygnalizator.", next="+"},
            {name="Omijam rogatkę i szybko przejeżdżam. Przecież zdążę. ", next="-"},
        }},
        {desc="Gdy widzę pojazd uprzywilejowany:",
        image="9.png",
        options={
            {name="Mi też się spieszy, jadę równo z nim.", next="-"},
            {name="Ustępuję mu pierwszeństwa, jeżeli to konieczne zatrzymam się lub zjeżdżam na chodnik.", next="+"},
        }},
        {desc="Włączając się do ruchu musisz:",
        image="10.png",
        options={
            {name="Upewnić się, że wyjazd jest bezpieczny i nie zagrażasz innym uczestnikom ruchu.", next="+"},
            {name="Dodać dużo gazu.", next="-"},
        }},
        {desc="Z jaką maksymalną prędkością masz prawo poruszać się w terenie zabudowanym?",
        image="11.png",
        options={
            {name="100 km/h", next="-"},
            {name="60 km/h", next="+"},
            {name="140 km/h", next="-"},
        }},
        {desc="Poruszasz się autostradą i zamierzasz ją opuścić. W którym miejscu rozpoczniesz hamowanie przed zjazdem z autostrady?",
        image="12.png",
        options={
            {name="Przed wjazdem na pas wyłączenia (zjazdu).", next="-"},
            {name="Po wjeździe na początek pasa wyłączenia (zjazdu).", next="+"},
            {name="W dowolnym miejscu na autostradzie.", next="-"},
        }},
        {desc="Jaka pozycja za kierownicą umożliwi zmniejszenie efektu tzw. martwego pola w lusterkach, występującego w czasie obserwacji drogi?",
        image="13.png",
        options={
            {name="Statyczna, sztywne siedzenie na fotelu, bez ruchów tułowia i głowy.", next="-"},
            {name="Dowolna, przede wszystkim dająca wygodę kierowania.", next="-"},
            {name="Dynamiczna, w zależności od sytuacji odchylanie tułowia i głowy od fotela.", next="+"},
        }},
        {desc="Czy w tej sytuacji masz obowiązek ustąpić pierwszeństwa pojazdowi, który nadjeżdża z prawej strony?",
        image="14.png",
        options={
            {name="Tak", next="-"},
            {name="Nie", next="+"},
        }},
        {desc="Zamierzasz skręcić w lewo, a kierujący pojazdem z przeciwka będzie jechać na wprost. Czy masz przed nim pierwszeństwo?",
        image="15.png",
        options={
            {name="Nie", next="+"},
            {name="Tak", next="-"},
        }},
        {desc="Czy spożyty alkohol wpływa na zmianę pola widzenia kierującego pojazdem?",
        image="16.png",
        options={
            {name="Tak", next="+"},
            {name="Nie", next="-"},
        }},
        {desc="Czy w tak oznakowanym miejscu wolno Ci zmienić pas ruchu?",
        image="17.png",
        options={
            {name="Tak, w każdej sytuacji", next="-"},
            {name="Tak jeżeli nie zagraża to innym uczestnikom ruchu", next="+"},
            {name="Nie", next="-"},
        }},
        {desc="Czy w przedstawionej sytuacji wjeżdżając na to skrzyżowanie musisz się bezwzględnie zatrzymać?",
        image="18.png",
        options={
            {name="Nie", next="-"},
            {name="Tak", next="+"},
        }},
        {desc="Czy przejeżdżając obok pieszego masz obowiązek zachować bezpieczny odstęp?",
        image="19.png",
        options={
            {name="Tak", next="+"},
            {name="Nie", next="-"},
        }},
        {desc="Czy masz prawo użyć sygnału dźwiękowego, by ostrzec innych przed bezpośrednim niebezpieczeństwem?",
        image="20.png",
        options={
            {name="Nie", next="-"},
            {name="Tak", next="+"},
        }},
    },

    ["C"]={
        {desc="Kierujesz samochodem ciężarowym. Który z wymienionych czynników jesteś zobowiązany uwzględnić, aby zachować bezpieczny odstęp od poprzedzającego pojazdu?",
        image="c1.png",
        options={
            {name="Prędkość pojazdów.", next="+"},
            {name="Moc silnika.", next="-"},
            {name="Szerokość pojazdów.", next="-"},
        }},
      
        {desc="Czy zażywanie leków nasennych i uspokajających może mieć negatywny wpływ na zdolność prowadzenia pojazdu?",
        image="c9.png",
        options={
            {name="Tak.", next="+"},
            {name="Nie.", next="-"},
        }},
      
        {desc="Jak powinieneś pokonywać zakręty samochodem ciężarowym?",
        image="c8.png",
        options={
            {name="Płynnie korygować tor jazdy uwzględniając krzywiznę zakrętu.", next="+"},
            {name="Pokonywać zakręt z wciśniętym pedałem sprzęgła.", next="-"},
            {name="Utrzymywać maksymalne obroty silnika na całej długości zakrętu.", next="-"},
        }},
      
        {desc="Jak należy się zachować w przypadku pomylenia zjazdu na drodze o wzmożonym ruchu?",
        image="c7.png",
        options={
            {name="Zatrzymać się przed pierwszą sygnalizacją świetlną, aby zapytać pieszych o dalszą drogę.", next="-"},
            {name="Podczas nieprzerwanej jazdy sprawdzić na mapie drogę powrotną.", next="-"},
            {name="Jechać dalej do miejsca, w którym będzie możliwe bezpieczne zatrzymanie pojazdu.", next="+"},
        }},
      
        {desc="Czy poruszając się pojazdem ponad gabarytowym kierujący ma obowiązek zachować szczególną ostrożność?",
        image="c5.png",
        options={
            {name="Tak.", next="+"},
            {name="Nie.", next="-"},
            {name="Tak, ale tylko w godzinach 22:00-5:00.", next="-"},
        }},
      
        {desc="W jaki sposób należy umieścić ładunek w samochodzie ciężarowym?",
        image="c6.png",
        options={
            {name="Tak, aby nie przekraczał całkowitej szerokości pojazdu.", next="+"},
            {name="Tak, aby nie wystawał z tyłu na odległość większą niż 1 metr od tylnej płaszczyzny obrysu pojazdu.", next="-"},
            {name="Tak, aby nie naruszał stateczności pojazdu i nie utrudniał kierowania.", next="-"},
        }},
      
        {desc="Co może być skutkiem zbyt niskiego poziomu oleju w silniku spalinowym?",
        image="c4.png",
        options={
            {name="Wzrost ciśnienia oleju.", next="-"},
            {name="Zatarcie czopów wału korbowego, panewek i tłoków.", next="+"},
            {name="Spadek temperatury pracy silnika.", next="-"},
        }},
      
        {desc="Jakie mogą być skutki niezapięcia pasów bezpieczeństwa przez kierowcę?",
        image="c3.png",
        options={
            {name="Większe obrażenia ciała kierowcy podczas wypadku.", next="+"},
            {name="Uszkodzenie poduszki powietrznej.", next="-"},
            {name="Większe uszkodzenia pojazdu podczas kolizji.", next="-"},
        }},
      
        {desc="O czym ostrzega, świecąca się na czerwono w czasie jazdy samochodem osobowym, lampka kontrolna z symbolem akumulatora?",
        image="c2.png",
        options={
            {name="Nieprawidłowo działającym ładowaniu akumulatora.", next="+"},
            {name="Całkowitym rozładowaniu się akumulatora.", next="-"},
            {name="Uszkodzeniu akumulatora.", next="-"},
        }},
      
        {desc="Która z wymienionych czynności jest dozwolona podczas kierowania samochodem osobowym?",
        image="c10.png",
        options={
            {name="Korzystanie z nawigacji.", next="+"},
            {name="Odpinanie pasa bezpieczeństwa.", next="-"},
            {name="Korzystanie z telefonu wymagającego trzymania słuchawki w ręku.", next="-"},
        }},
    },

    ["C+E"]={
        {desc="Wjeżdżając na skrzyżowanie bez sygnalizacji świetlnej wiedząc, że na naczepie masz spory ładunek:",
        image="ce1.png",
        options={
            {name="Zachowuje ostrożność i rozglądam się.", next="+"},
            {name="Wjeżdżam na skrzyżowanie niezważając na innych uczestników ruchu.", next="-"},
            {name="Przed wjazdem na skrzyżowanie upewniam się czy mój ładunek został nienaruszony.", next="-"},
        }},
    
        {desc="Który z pojazdów na zdjęciu ma pierwszeństwo?",
        image="ce2.png",
        options={
            {name="Pojazd A ma pierwszeństwo.", next="-"},
            {name="Pojazd B ma pierwszeństwo.", next="+"},
        }},
    
        {desc="Widząc ciężarówke, która jedzie prawym pasem na autostradzie:",
        image="ce3.png",
        options={
            {name="Tworzę kolumnę i jadę za drugą ciężarówką, aby nie blokować innych.", next="+"},
            {name="Wjeżdżam na lewy pas tak, aby zablokować całkowicie ruch.", next="-"},
        }},
    
        {desc="Włączając się do ruchu upewniam się, że:",
        image="ce4.png",
        options={
            {name="Nie zagrażam życiu ani zdrowiu innemu uczestnikowi ruchu.", next="+"},
            {name="Są jakieś atrakcje w pobliżu, które warto odwiedzić.", next="-"},
        }},
    
        {desc="Jaka jest kolejność jazdy, którą zachowają pojazdy na obrazku?",
        image="ce5.png",
        options={
            {name="Pojazd B pojedzie pierwszy, a za nim pojazd A.", next="-"},
            {name="Pojazd A pojedzie pierwszy, a za nim pojazd B.", next="+"},
        }},
    
        {desc="Przed rozpoczęciem jazdy upewniam się, że:",
        image="ce6.png",
        options={
            {name="Zabrałem ze sobą prowiant i że dotre na czas.", next="-"},
            {name="Mój pojazd, którym się poruszam jest zdatny do jazdy.", next="+"},
        }},
    
        {desc="Widzisz pojazd uprzywilejowany z włączonymi sygnałamy dźwiękowymi i świetlnymi, co robisz?",
        image="ce7.png",
        options={
            {name="Dodaję gazu i nie pozwalam, aby mnie wyprzedził.", next="-"},
            {name="Staram się, aby przejechał bezpiecznie i zwalniam.", next="+"},
        }},
    
        {desc="Jedziesz ciężarówką z bardzo ciężkim ładunkiem, warunki atmosferyczne nie sprzyjają standardowej jeździe, jak się zachowujesz?",
        image="ce8.png",
        options={
            {name="Jadę jak najszybciej, ponieważ chcę się dostać do punktu odbioru na czas.", next="-"},
            {name="Spuszczam nogę z pedału gazu.", next="+"},
        }},
    
        {desc="Podczas jazdy z długą naczepą:",
        image="ce9.png",
        options={
            {name="Nie zwracam uwagi na nikogo, ponieważ inni powinni na mnie uważać.", next="-"},
            {name="Upewniam się, że nie uszkodzę nikogo na jakimkolwiek skrzyżowaniu.", next="+"},
        }},
    
        {desc="Widzisz nieprzytomną osobę na poboczu:",
        image="ce10.png",
        options={
            {name="Nie zwracam na nią uwagi i jadę dalej.", next="-"},
            {name="Zatrzymuję się, udzielam pierwszej pomocy i wzywam służby.", next="+"},
            {name="Jadę dalej i powiadamiam służby.", next="-"},
        }},
    },

    ["L"]={
        {desc="Jakimi pojazdami powietrznymi możesz poruszać się posiadając licencję 'L'?",
        image="l1.png",
        options={
            {name="Tylko samolotami.", next="+"},
            {name="Wszystkimi dostępnymi pojazdami lądowymi.", next="-"},
            {name="Tylko helikopterami.", next="-"},
        }},
    
        {desc="Jakie warunki musi spełniać pojazd aby pilot zdecydował się na start?",
        image="l2.png",
        options={
            {name="Powłoka lakiernicza musi być w nienagannym stanie.", next="-"},
            {name="Sprawdzone muszą zostać silniki, elementy poszycia oraz systemy bezpieczeństwa.", next="+"},
            {name="Pełen barek alkoholu pokładowego.", next="-"},
        }},
    
        {desc="Do czego służą lotki w samolocie?",
        image="l3.png",
        options={
            {name="Do przechylania samolotu.", next="+"},
            {name="Do informowania o zamiarze lądowania.", next="-"},
            {name="Nie spełniają żadnej funkcji, są dla dekoracji.", next="-"},
        }},
    
        {desc="Co oznacza termin 'Przyciągnięcie'?",
        image="l4.png",
        options={
            {name="Zbliżanie się do pasa podczas lądowania.", next="-"},
            {name="Nagły spadek prędkości i utrata siły lotu.", next="+"},
            {name="Duże przeciążenia powodujące wciskanie w fotel.", next="-"},
        }},
    
        {desc="Jakie kroki należy podjąć przed lądowaniem?",
        image="l5.png",
        options={
            {name="Upewnić się, że pas na który kołujemy jest wolny.", next="+"},
            {name="Zwiększyć prędkość.", next="-"},
            {name="Podejmować szybkie gwałtowne kroki.", next="-"},
        }},
    
        {desc="W trakcie lotu silnik samolotu doznał uszkodzenia:",
        image="l6.png",
        options={
            {name="Wszczynam procedurę awaryjną, szukam najbezpieczniejszego miejsca do lądowania.", next="+"},
            {name="Próbuję dolecieć do określonego celu, a dopiero tam podjąć kroki naprawcze.", next="-"},
        }},
    
        {desc="Pierwszą czynnością załogi statku powietrznego po lądowaniu awaryjnym  i wystąpieniu pożaru zagrażającemu życiu lub zdrowiu pasażerów lub członków załogi jest:",
        image="l7.png",
        options={
            {name="Ugaszenie pożaru.", next="-"},
            {name="Ratowanie rannych.", next="+"},
            {name="Oddalenie się na bezpieczną odległość", next="-"},
        }},
    
        {desc="Czym powinien kierować się pilot w wyborze miejsca do lądowania awaryjnego:",
        image="l8.png",
        options={
            {name="Utwardzeniem terenu, pochyłością, ogólnie czynnikami bezpieczeństwa.", next="+"},
            {name="Widokami krajobrazu.", next="-"},
            {name="Jak najmniejszymi stratami finansowymi", next="-"},
        }},
    
        {desc="Jakie warunki należy spełnić aby móc wykonywać zrzuty powietrzne?",
        image="l9.png",
        options={
            {name="Zapięte pasy.", next="-"},
            {name="Posiadać odpowiednie zezwolenie wydawane przy lotach towarowych.", next="+"},
            {name="Odpowiedni kolor poszycia.", next="-"},
        }},
    
        {desc="Wybierz prawidłowo sytuację w których pilot zobowiązany jest skontaktować się ze służbami ratunkowymi:",
        image="l10.png",
        options={
            {name="Nagły spadek płac pilotów towarowych.", next="-"},
            {name="Pożar, sytuacje utraty życia lub zdrowia.", next="+"},
            {name="Zmiana kursu złota.", next="-"},
        }},
    }
}
