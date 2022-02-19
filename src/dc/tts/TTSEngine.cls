/// TTS engine
Class dc.tts.TTSEngine
{

/// Text to audio file
ClassMethod GenerateAudioFileFromText(sentence, language, domain) [ Language = python ]
{
        from gtts import gTTS
        import uuid

        tts = gTTS(sentence, lang=str(language), tld=str(domain))
        output = str(uuid.uuid1()) + '.mp3'
        tts.save('/opt/irisbuild/' + output)
        return output
}

}
