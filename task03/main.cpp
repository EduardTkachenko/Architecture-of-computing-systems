// Tkachenko Eduard
// Вариант 26

#include <cassert>
#include <iostream>
#include <vector>
#include <thread>

// Поиск в строке nmbI контейнера map местоположения элемента со значением true.
void find(std::vector<std::vector<bool>>& map, int nmbI, int &ans_i, int &ans_j, char &finish) {
    for (int j = 0; j < map[nmbI].size(); ++j) {
        if (map[nmbI][j]) {
            ans_i = nmbI;
            ans_j = j;
            finish = 0;
            return;
        }
    }
    finish = 0;
}

int main() {
    int n; // Размер карты во высоте.
    int m; // Размер карты по ширине.
    int k; // Количество потоков (команд Флинта).

    std::cout << "Map size in height:";
    std::cin >> n;
    std::cout << "Map size in width:";
    std::cin >> m;
    std::cout << "Number of teams:";
    std::cin >> k;
    if (k <= 0 || n <= 0 || m <= 0) {
        std::cout << "Incorrect input.";
        return 0;
    }

    std::vector<std::vector<bool>> map(n, std::vector<bool>(m)); // Карта сокровищ.
    map[rand() % n][rand() % m] = true; // Генерация координат сокровищ.
    int ans_i = -1, ans_j = -1; // Местоположение сокровищ
    int curI = 0; // Номер строки для вызова find очередным потоком.
    std::vector<std::thread> threads(k); // Возможные потоки
    std::vector<char> is_run(k); // Отслеживание работы потоков

    while (ans_i == -1) {
        for (int i = 0; i < threads.size(); ++i) {
            if (!is_run[i] && curI != n) {
                if (threads[i].joinable())
                    threads[i].join();
                is_run[i] = 1;
                threads[i] = std::thread(find, std::ref(map), curI++, std::ref(ans_i), std::ref(ans_j), std::ref(is_run[i]));
            }
        }
    }
    for (int i = 0; i < k; ++i) {
        if (threads[i].joinable())
            threads[i].join();
    }
    std::cout << "Treasure map: \n";
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < m; ++j) {
            std::cout << (map[i][j] ? 'X' : '0'); // 'X' - сокровище, '0' - нет сокровища
        }
        std::cout << std::endl;
    }
    std::cout << "Treasure coordinates (numbered from 0): " << ans_i << ' ' << ans_j;
    getchar();
    getchar();
    return 0;
}
