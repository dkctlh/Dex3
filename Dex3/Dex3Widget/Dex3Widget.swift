//
//  Dex3Widget.swift
//  Dex3Widget
//
//  Created by Talha Dikici on 24.09.2024.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: AppIntentTimelineProvider {
    
    var randomPokemon: Pokemon {
        let context = PersistenceController.shared.container.viewContext
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        
        var results: [Pokemon] = []
        
        do {
            results = try context.fetch(fetchRequest)
        } catch {
            print("Couldn't fetch: \(error)")
        }
        
        if let randomPokemon = results.randomElement() {
            return randomPokemon
        }
        
        return SamplePokemon.samplePokemon
    }
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), pokemon: SamplePokemon.samplePokemon, configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), pokemon: randomPokemon, configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, pokemon: randomPokemon, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let pokemon: Pokemon
    let configuration: ConfigurationAppIntent
}

struct Dex3WidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetSize
    var entry: Provider.Entry

    var body: some View {
        switch widgetSize {
        case .systemSmall:
            WidgetPokemon(widgetSize: .small)
                .environmentObject(entry.pokemon)
        case .systemMedium:
            WidgetPokemon(widgetSize: .medium)
                .environmentObject(entry.pokemon)
        case .systemLarge:
            WidgetPokemon(widgetSize: .large)
                .environmentObject(entry.pokemon)
        default:
            WidgetPokemon(widgetSize: .large)
                .environmentObject(entry.pokemon)
        }
    }
}

struct Dex3Widget: Widget {
    let kind: String = "Dex3Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Dex3WidgetEntryView(entry: entry)
                .containerBackground(Color(entry.pokemon.types![0].capitalized), for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    Dex3Widget()
} timeline: {
    SimpleEntry(date: .now, pokemon: SamplePokemon.samplePokemon, configuration: .smiley)
}

#Preview(as: .systemMedium) {
    Dex3Widget()
} timeline: {
    SimpleEntry(date: .now, pokemon: SamplePokemon.samplePokemon, configuration: .smiley)
}

#Preview(as: .systemLarge) {
    Dex3Widget()
} timeline: {
    SimpleEntry(date: .now, pokemon: SamplePokemon.samplePokemon, configuration: .smiley)

}
