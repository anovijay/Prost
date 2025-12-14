//
//  SelectableTextView.swift
//  Prost
//
//  A UITextView wrapper that supports proper word selection with custom context menu
//

import SwiftUI
import UIKit

struct SelectableTextView: UIViewRepresentable {
    let text: String
    let onWordSelected: (String) -> Void
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.font = .systemFont(ofSize: 17, weight: .regular)
        textView.textColor = .label
        
        // Add custom context menu interaction
        textView.addInteraction(UIContextMenuInteraction(delegate: context.coordinator))
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != text {
            textView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate, UIContextMenuInteractionDelegate {
        let parent: SelectableTextView
        
        init(_ parent: SelectableTextView) {
            self.parent = parent
        }
        
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            configurationForMenuAtLocation location: CGPoint
        ) -> UIContextMenuConfiguration? {
            guard let textView = interaction.view as? UITextView else { return nil }
            
            // Get selected text or word at tap location
            let selectedText = textView.selectedText ?? getWordAtLocation(location, in: textView)
            
            guard !selectedText.isEmpty else { return nil }
            
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                let addWordAction = UIAction(
                    title: "Add '\(selectedText)' to Word List",
                    image: UIImage(systemName: "plus.circle")
                ) { [weak self] _ in
                    self?.parent.onWordSelected(selectedText)
                }
                
                // Include standard actions (Copy, Share)
                let copyAction = UIAction(
                    title: "Copy",
                    image: UIImage(systemName: "doc.on.doc")
                ) {_ in
                    UIPasteboard.general.string = selectedText
                }
                
                return UIMenu(title: "", children: [addWordAction, copyAction])
            }
        }
        
        private func getWordAtLocation(_ location: CGPoint, in textView: UITextView) -> String {
            // Convert tap location to text position
            let tapLocation = textView.closestPosition(to: location)
            
            guard let tapLocation = tapLocation else { return "" }
            
            // Get the word range at tap location
            let tokenizer = textView.tokenizer
            guard let wordRange = tokenizer.rangeEnclosingPosition(
                tapLocation,
                with: .word,
                inDirection: UITextDirection(rawValue: 1)
            ) else { return "" }
            
            // Extract the word
            guard let word = textView.text(in: wordRange) else { return "" }
            
            return word
        }
    }
}

extension UITextView {
    var selectedText: String? {
        guard let selectedRange = selectedTextRange else { return nil }
        return text(in: selectedRange)
    }
}

// MARK: - SwiftUI Wrapper with Styling

struct StyledSelectableTextView: View {
    let text: String
    let onWordSelected: (String) -> Void
    
    var body: some View {
        SelectableTextView(text: text, onWordSelected: onWordSelected)
            .frame(minHeight: calculateHeight())
    }
    
    private func calculateHeight() -> CGFloat {
        // Use a reasonable default width that works for most devices
        let estimatedWidth: CGFloat = 350
        let font = UIFont.systemFont(ofSize: 17, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).boundingRect(
            with: CGSize(width: estimatedWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        return ceil(size.height) + 20
    }
}

