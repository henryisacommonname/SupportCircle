import 'package:flutter/material.dart';

import '../models/app_resource.dart';
import '../models/training_module.dart';

const List<TrainingModule> defaultTrainingModules = [
  TrainingModule(
    id: 'default_mod_1',
    title: 'Safeguarding Basics: Child Safety and Boundaries',
    subtitle:
        'Recognize risk, maintain clear boundaries, and report concerns quickly.',
    minutes: 12,
    order: 1,
    body:
        'Volunteers should prioritize safety in every interaction. Keep communication age-appropriate, avoid one-on-one isolated situations, and follow your site check-in and check-out procedures.\n\n'
        'If a child shares something concerning, listen calmly, do not promise secrecy, and escalate immediately to your site coordinator using approved reporting steps.\n\n'
        'Your role is to support, document facts objectively, and hand off to trained staff for further action.',
    imageURL:
        'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=1400&q=80',
  ),
  TrainingModule(
    id: 'default_mod_2',
    title: 'Trauma-Informed Communication',
    subtitle: 'Use language that builds trust and emotional safety.',
    minutes: 15,
    order: 2,
    body:
        'Many children and families have experienced stress or trauma. Use a calm tone, simple instructions, and choices when possible. Ask permission before offering help and avoid judgmental phrasing.\n\n'
        'Focus on what a participant needs right now: safety, clarity, and consistency. Validate feelings without forcing personal disclosures.\n\n'
        'If someone becomes overwhelmed, give space, reduce stimulation, and notify staff for additional support.',
    imageURL:
        'https://images.unsplash.com/photo-1469571486292-b53601020e6e?auto=format&fit=crop&w=1400&q=80',
  ),
  TrainingModule(
    id: 'default_mod_3',
    title: 'Inclusive Volunteering for Neurodiverse Youth',
    subtitle: 'Adapt activities so every participant can engage with dignity.',
    minutes: 14,
    order: 3,
    body:
        'Inclusive volunteering means offering multiple ways to participate. Provide visual cues, step-by-step guidance, and optional sensory breaks during activities.\n\n'
        'Use person-first or identity-first language based on participant preference, and do not assume ability level from diagnosis.\n\n'
        'When in doubt, ask: "What support helps you participate best today?" Then coordinate with staff to adjust pacing, instructions, or environment.',
    imageURL:
        'https://images.unsplash.com/photo-1511895426328-dc8714191300?auto=format&fit=crop&w=1400&q=80',
  ),
  TrainingModule(
    id: 'default_mod_4',
    title: 'De-escalation and Conflict Response',
    subtitle: 'Respond to tense moments without increasing stress.',
    minutes: 13,
    order: 4,
    body:
        'When conflict appears, lower your voice, keep your body language open, and avoid crowding participants. Acknowledge feelings and set clear, respectful limits.\n\n'
        'Use short statements such as "I hear you. Let us take a breath and step aside." Offer one next action at a time and involve staff early if safety is uncertain.\n\n'
        'After the situation stabilizes, document what happened, what was tried, and any follow-up needed.',
    imageURL:
        'https://images.unsplash.com/photo-1526634332515-d56c5fd16991?auto=format&fit=crop&w=1400&q=80',
  ),
  TrainingModule(
    id: 'default_mod_5',
    title: 'Program Logistics, Attendance, and Follow-Up',
    subtitle:
        'Close each volunteer session with accurate records and next steps.',
    minutes: 10,
    order: 5,
    body:
        'Consistent operations make programs safer and more reliable. Arrive early, review your assignment, and confirm emergency contacts and attendance procedures.\n\n'
        'At the end of each shift, record service hours, note meaningful outcomes, and flag unresolved issues for staff.\n\n'
        'Strong follow-up helps teams plan better support for children and families in future sessions.',
    imageURL:
        'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1400&q=80',
  ),
];

const List<AppResource> defaultResources = [
  AppResource(
    id: 'default_res_1',
    title: 'Getting Started with Local Volunteering',
    subtitle: 'Find the right program and complete onboarding confidently.',
    icon: Icons.call,
    body:
        'Pick one cause area, verify age requirements, and confirm orientation details before committing. Bring valid identification to onboarding and ask about required training in advance.',
  ),
  AppResource(
    id: 'default_res_2',
    title: 'Volunteering at Senior Centers',
    subtitle: 'Communication tips for respectful and meaningful support.',
    icon: Icons.school_outlined,
    body:
        'Introduce yourself clearly, speak at a steady pace, and keep conversations participant-led. If someone seems distressed, notify staff and follow their guidance.',
  ),
  AppResource(
    id: 'default_res_3',
    title: 'Community Cleanup Safety',
    subtitle: 'Plan safe and effective neighborhood or beach cleanup events.',
    icon: Icons.menu_book_outlined,
    body:
        'Wear gloves and closed-toe shoes, sort waste correctly, and report hazardous items to local authorities instead of handling them directly.',
  ),
];
